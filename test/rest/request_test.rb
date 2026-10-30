# frozen_string_literal: true

require_relative '../test_helper'

module REST
  class RequestTest < REST::Test
    def setup
      stub_request(:any, /example\.com/).to_return(
        status: 200,
        body: 'It works!',
        headers: { 'Content-Type' => 'text/html' }
      )
    end

    test 'GETs a resource' do
      request = Request.new(:get, URI.parse('http://example.com/resources/1'))
      response = request.perform

      assert_equal '/resources/1', request.request.path
      assert_equal 200, response.status_code
      assert_equal 'It works!', response.body
    end

    test 'GETs a resource without a path' do
      request = Request.new(:get, URI.parse('http://example.com'))
      response = request.perform

      assert_equal '/', request.request.path
      assert_equal 200, response.status_code
      assert_equal 'It works!', response.body
    end

    test 'GETs a resource including a query' do
      request = Request.new(:get, URI.parse('http://example.com/resources?q=first'))
      response = request.perform

      assert_equal '/resources?q=first', request.request.path
      assert_equal 200, response.status_code
      assert_equal 'It works!', response.body
    end

    test 'GETs a resource with an entity body' do
      body = 'return=false'
      request = Request.new(:get, URI.parse('http://example.com/resources/1'), body)
      response = request.perform

      assert_equal 200, response.status_code
      assert_equal body, request.request.body
      assert_equal '/resources/1', request.request.path
      assert_equal 'It works!', response.body
    end

    test 'GETs a resource from an HTTPS URL' do
      request = Request.new(:get, URI.parse('https://example.com/resources/1'))
      response = request.perform

      assert_equal 200, response.status_code
      assert_equal 'It works!', response.body
    end

    test 'HEADs a resource' do
      request = Request.new(:head, URI.parse('http://example.com/resources/1'))
      response = request.perform

      assert_equal 200, response.status_code
    end

    test 'DELETEs a resource' do
      request = Request.new(:delete, URI.parse('http://example.com/resources/1'))
      response = request.perform

      assert_equal 200, response.status_code
    end

    test 'DELETEs a resource with an entity body' do
      body = 'hello'
      request = Request.new(:delete, URI.parse('http://example.com/resources/1'), body)
      response = request.perform

      assert_equal body, request.request.body
      assert_equal 200, response.status_code
    end

    test 'PATCHes a resource' do
      body = 'name=Manfred'
      request = Request.new(:patch, URI.parse('http://example.com/resources/1'), body)
      response = request.perform

      assert_equal 200, response.status_code
      assert_equal body, request.request.body
      assert_equal 'It works!', response.body
    end

    test 'PUTs a resource' do
      body = 'name=Manfred'
      request = Request.new(:put, URI.parse('http://example.com/resources/1'), body)
      response = request.perform

      assert_equal 200, response.status_code
      assert_equal body, request.request.body
      assert_equal 'It works!', response.body
    end

    test 'POSTs a resource' do
      body = 'name=Manfred'
      request = Request.new(:post, URI.parse('http://example.com/resources'), body)
      response = request.perform

      assert_equal 200, response.status_code
      assert_equal body, request.request.body
      assert_equal 'It works!', response.body
    end

    test 'moves the body to the underlying request object' do
      body = 'It works!'
      request = Request.new(:post, URI.parse('http://example.com/resources'), body)
      request.perform

      assert_equal body, request.request.body
    end

    test 'moves headers to the underlying request object' do
      headers = { 'Accepts' => 'text/html', 'X-Helo' => 'Hi there!' }
      request = Request.new(:post, URI.parse('http://example.com/resources'), '', headers)
      request.perform

      headers.each do |name, value|
        assert_equal value, request.request[name]
      end
    end

    test 'moves the response headers to the response object' do
      request = Request.new(:get, URI.parse('http://example.com/resources/1'))
      response = request.perform

      assert_equal ['text/html'], response.headers['content-type']
    end

    test 'moves basic authentication credentials to the underlying request object' do
      request = Request.new(
        :post,
        URI.parse('http://example.com/resources'),
        '',
        {},
        { username: 'admin', password: 'secret' }
      )
      request.perform

      assert_equal 'Basic YWRtaW46c2VjcmV0', request.request['authorization']
    end

    test 'sets attributes for checking the server certificate during a TLS connection' do
      request = Request.new(
        :get, URI.parse('https://example.com/resources'), '', {}, { tls_verify: true }
      )
      http_request = request.http_request

      assert http_request.use_ssl?
      assert_equal File.join(GEM_ROOT, 'support/cacert.pem'), http_request.ca_file
      assert_equal OpenSSL::SSL::VERIFY_PEER, http_request.verify_mode
    end

    test 'sets TLS key and certificate on the underlying request object' do
      contents = File.read(fixture_file('recorder-1.pem'))
      key = OpenSSL::PKey::RSA.new(contents)
      certificate = OpenSSL::X509::Certificate.new(contents)

      request = Request.new(
        :get,
        URI.parse('https://example.com/resources'),
        '',
        {},
        { tls_key: key, tls_certificate: certificate }
      )
      http_request = request.http_request

      assert_equal key.to_pem, http_request.key.to_pem
      assert_equal certificate.to_pem, http_request.cert.to_pem
    end

    test 'sets TLS key and certificate on the underlying request object from a file' do
      request = Request.new(
        :get,
        URI.parse('https://example.com/resources'),
        '',
        {},
        { tls_key_and_certificate_file: fixture_file('recorder-1.pem') }
      )
      http_request = request.http_request

      contents = File.read(fixture_file('recorder-1.pem'))
      assert_equal OpenSSL::PKey::RSA.new(contents).to_pem, http_request.key.to_pem
      assert_equal OpenSSL::X509::Certificate.new(contents).to_pem, http_request.cert.to_pem
    end

    test 'sets the TLS CA file on the underlying request object' do
      request = Request.new(
        :get,
        URI.parse('https://example.com/resources'),
        '',
        {},
        { tls_verify: true, tls_ca_file: fixture_file('recorder-1.pem') }
      )

      assert_equal fixture_file('recorder-1.pem'), request.http_request.ca_file
    end

    test 'raises an argument error for unknown verbs' do
      request = Request.new(:unknown, URI.parse(''))

      assert_raises(ArgumentError) { request.perform }
    end

    test 'raises a disconnect error when reading the response fails' do
      stub_request(:get, 'http://example.com/something').to_raise(EOFError.new('failed'))

      assert_raises(EOFError) { REST.get('http://example.com/something') }
    end

    test 'finds http proxy settings from the environment' do
      request = Request.new(:get, URI.parse(''))
      assert_nil request.http_proxy

      with_env('HTTP_PROXY' => 'http://localhost') do
        assert_equal 'http://localhost', request.proxy_env['http']
      end

      with_env('http_proxy' => 'http://rob:secret@192.168.0.1:21') do
        assert_equal 'http://rob:secret@192.168.0.1:21', request.proxy_env['http']
      end
    end

    test 'finds https proxy settings from the environment' do
      request = Request.new(:get, URI.parse(''))
      assert_nil request.proxy_settings

      with_env('HTTPS_PROXY' => 'http://localhost') do
        assert_equal 'http://localhost', request.proxy_env['https']
      end

      with_env('https_proxy' => 'http://rob:secret@192.168.0.1:21') do
        assert_equal 'http://rob:secret@192.168.0.1:21', request.proxy_env['https']
      end
    end

    test 'parses the http proxy settings' do
      with_env('HTTP_PROXY' => 'http://rob:secret@192.168.0.1:21') do
        settings = Request.new(:get, URI.parse('http://example.com')).proxy_settings

        assert_equal '192.168.0.1', settings.host
        assert_equal 21, settings.port
        assert_equal 'rob', settings.user
        assert_equal 'secret', settings.password
      end
    end

    test 'parses the https proxy settings' do
      with_env('HTTPS_PROXY' => 'http://rob:secret@192.168.0.1:21') do
        settings = Request.new(:get, URI.parse('https://example.com')).proxy_settings

        assert_equal '192.168.0.1', settings.host
        assert_equal 21, settings.port
        assert_equal 'rob', settings.user
        assert_equal 'secret', settings.password
      end
    end

    test 'does not return a proxy for any scheme when nothing is configured' do
      request = Request.new(:get, URI.parse('http://example.com/heya'))

      assert_nil request.http_proxy
    end

    test 'does not return a proxy object when a specific scheme is not configured' do
      with_env('HTTP_PROXY' => 'http://rob:secret@192.168.0.1:21') do
        request = Request.new(:get, URI.parse('https://example.com/heya'))

        assert_nil request.http_proxy
      end
    end

    test 'returns a proxy object when the specific scheme is configured' do
      with_env(
        'HTTP_PROXY' => 'http://192.168.0.1:80',
        'HTTPS_PROXY' => 'http://192.168.0.2:80'
      ) do
        request = Request.new(:get, URI.parse('http://example.com/heya'))
        assert_equal '192.168.0.1', request.http_proxy.proxy_address

        request = Request.new(:get, URI.parse('https://example.com/heya'))
        assert_equal '192.168.0.2', request.http_proxy.proxy_address
      end
    end

    test 'uses the proxy instead of a regular request object when a proxy is configured' do
      request = Request.new(:get, URI.parse('http://example.com/heya'))
      assert_kind_of Net::HTTP, request.http_request
      assert_nil request.http_request.proxy_address

      with_env(
        'HTTP_PROXY' => 'http://192.168.0.1:80',
        'HTTPS_PROXY' => 'http://192.168.0.2:80'
      ) do
        assert_kind_of Net::HTTP, request.http_request
        assert_equal '192.168.0.1', request.http_request.proxy_address
      end
    end

    test 'forwards the configure block when initializing a new request with perform' do
      yielded_http_request = nil
      Request.perform(:get, URI.parse('http://example.com/pigeon')) do |http_request|
        yielded_http_request = http_request
      end

      assert_kind_of Net::HTTP, yielded_http_request
    end

    test 'yields the underlying Net::HTTP request object for additional configuration' do
      yielded_http_request = nil
      request = Request.new(:get, URI.parse('http://example.com/heya')) do |http_request|
        yielded_http_request = http_request
      end
      http_request = request.http_request

      refute_nil http_request
      assert_same http_request, yielded_http_request
    end
  end
end
