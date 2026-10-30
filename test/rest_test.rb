# frozen_string_literal: true

require_relative 'test_helper'

module REST
  class RestTest < REST::Test
    def setup
      stub_request(:any, /example\.com/).to_return(status: 200, body: 'It works!')
    end

    test 'GETs a resource' do
      uri = 'http://example.com/resources/1'
      assert_equal 200, REST.get(uri).status_code
      assert_requested :get, uri
    end

    test 'HEADs a resource' do
      uri = 'http://example.com/resources/1'
      assert_equal 200, REST.head(uri).status_code
      assert_requested :head, uri
    end

    test 'DELETEs a resource' do
      uri = 'http://example.com/resources/1'
      assert_equal 200, REST.delete(uri).status_code
      assert_requested :delete, uri
    end

    test 'PATCHes a resource' do
      uri = 'http://example.com/resources/1'
      body = 'name=Manfred'
      assert_equal 200, REST.patch(uri, body).status_code
      assert_requested :patch, uri, body: body
    end

    test 'PUTs a resource' do
      uri = 'http://example.com/resources/1'
      body = 'name=Manfred'
      assert_equal 200, REST.put(uri, body).status_code
      assert_requested :put, uri, body: body
    end

    test 'POSTs a resource' do
      uri = 'http://example.com/resources'
      body = 'name=Manfred'
      assert_equal 200, REST.post(uri, body).status_code
      assert_requested :post, uri, body: body
    end

    test 'forwards headers to the request' do
      uri = 'http://example.com/resources/1'
      REST.get(uri, { 'Accept' => 'text/plain' })
      assert_requested :get, uri, headers: { 'Accept' => 'text/plain' }
    end

    test 'forwards options to the request' do
      uri = 'http://example.com/resources/1'
      REST.get(uri, {}, { username: 'admin', password: 'secret' })
      assert_requested :get, uri, headers: { 'Authorization' => 'Basic YWRtaW46c2VjcmV0' }
    end

    test 'forwards the configure block to the request' do
      timeout = 342
      yielded_http_request = nil
      REST.get('http://example.com/resources/2') do |http_request|
        http_request.open_timeout = timeout
        yielded_http_request = http_request
      end
      assert_equal timeout, yielded_http_request.open_timeout
    end
  end
end
