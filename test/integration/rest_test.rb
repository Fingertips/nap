# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../support/simple_service'

require 'open3'

module Integration
  class RestTest < REST::Test
    BASE_URL = "http://#{SimpleService::HOST}:#{SimpleService::PORT}".freeze

    def setup
      WebMock.disable_net_connect!(allow_localhost: true)
    end

    def teardown
      WebMock.disable_net_connect!
    end

    test 'returns the body of the response' do
      with_simple_service do
        response = REST.get(BASE_URL) do |http_request|
          http_request.open_timeout = 15
        end
        assert_equal 200, response.status_code
        assert_equal "OK!\n", response.body
      end
    end

    test 'returns the status code of an unknown path' do
      with_simple_service do
        response = REST.get("#{BASE_URL}/unknown")
        assert response.not_found?
        assert_equal "Unknown path: /unknown\n", response.body
      end
    end

    test 'raises an exception when the server disconnects' do
      with_simple_service do
        error = assert_raises(REST::Error::Connection) do
          REST.get("#{BASE_URL}/disconnect")
        end
        assert_equal 'end of file reached', error.message
      end
    end

    private

    def with_simple_service
      Open3.popen2e(
        'ruby', "#{SUPPORT_ROOT}/simple_service.rb"
      ) do |stdin, _output, thread|
        stdin.close
        wait_until(URI(BASE_URL))
        yield
      ensure
        Process.kill('TERM', thread.pid)
      end
    end

    def wait_until(uri)
      # Wait for the server to respond to the URI.
      120.times do
        Net::HTTP.get_response(uri)
      rescue Errno::ECONNREFUSED
        sleep 0.5
      else
        break
      end
    end
  end
end
