require File.expand_path('../helper', __FILE__)

require 'openssl'

describe "A REST Request" do
  before do
    http_response = Net::HTTPOK.new('1.1', '200', 'OK')
    http_response.read_body = 'It works!'
    http_response.add_field('Content-type', 'text/html')
    Net::HTTP.start_returns = http_response
  end
  
  it "should GET a resource" do
    request = REST::Request.new(:get, URI.parse('http://example.com/resources/1'))
    response = request.perform
    
    request.request.path.should == '/resources/1'
    response.status_code.should == 200
    response.body.should == 'It works!'
  end

  it "should GET a resource without a path" do
    request = REST::Request.new(:get, URI.parse('http://example.com'))
    response = request.perform

    request.request.path.should == '/'
    response.status_code.should == 200
    response.body.should == 'It works!'
  end

  it "should GET a resource including a query" do
    request = REST::Request.new(:get, URI.parse('http://example.com/resources?q=first'))
    response = request.perform
    
    request.request.path.should == '/resources?q=first'
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should HEAD a resource" do
    request = REST::Request.new(:head, URI.parse('http://example.com/resources/1'))
    response = request.perform
    
    response.status_code.should == 200
  end
  
  it "should DELETE a resource" do
    request = REST::Request.new(:delete, URI.parse('http://example.com/resources/1'))
    response = request.perform
    
    response.status_code.should == 200
  end
  
  it "should PATCH a resource" do
    body = 'name=Manfred'
    request = REST::Request.new(:put, URI.parse('http://example.com/resources/1'), body)
    
    response = request.perform
    request.request.body.should == body
    
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should PUT a resource" do
    body = 'name=Manfred'
    request = REST::Request.new(:put, URI.parse('http://example.com/resources/1'), body)
    
    response = request.perform
    request.request.body.should == body
    
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should POST a resource" do
    body = 'name=Manfred'
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), body)
    
    response = request.perform
    request.request.body.should == body
    
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should move body to the underlying request object" do
    body = 'It works!'
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), body)
    request.perform
    request.request.body.should == body
  end
  
  it "should move headers to the underlying request object" do
    headers = {'Accepts' => 'text/html', 'X-Helo' => 'Hi there!'}
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), '', headers)
    request.perform
    headers.each do |name, value|
      request.request[name].should == value
    end
  end
  
  it "should move the response headers to the REST::Response object" do
    request = REST::Request.new(:get, URI.parse('http://example.com/resources/1'))
    response = request.perform
    response.headers['content-type'].should == ['text/html']
  end
  
  it "should move basic authentication credentials to the underlying request object" do
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), '', {}, {:username => 'admin', :password => 'secret'})
    request.perform
    request.request['authorization'].should == "Basic YWRtaW46c2VjcmV0"
  end
  
  it "should set the proper attributes for checking the server certificate during a TLS connection" do
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, { :tls_verify => true })
    request.perform
    http_request = REST::Request._last_http_request
    
    http_request.use_ssl?.should == true
    
    if http_request.respond_to?(:enable_post_connection_check=)
      http_request.enable_post_connection_check.should == true
    end
    
    http_request.ca_file.should == File.expand_path('../../support/cacert.pem', __FILE__)
    http_request.verify_mode.should == OpenSSL::SSL::VERIFY_PEER
  end
  
  it "should set TLS key and certificate to the underlying request object" do
    key = OpenSSL::PKey::RSA.new(file_fixture_contents('recorder-1.pem'))
    certificate = OpenSSL::X509::Certificate.new(file_fixture_contents('recorder-1.pem'))
    
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {
      :tls_key => key,
      :tls_certificate => certificate
    })
    request.perform
    http_request = REST::Request._last_http_request
    
    http_request.key.to_s.should == key.to_s
    http_request.cert.to_s.should === certificate.to_s
  end
  
  it "should set TLS key and certificate to the underlying request object when passed a key file" do
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {:tls_key_and_certificate_file => file_fixture('recorder-1.pem') })
    request.perform
    http_request = REST::Request._last_http_request
    
    expected_key = OpenSSL::PKey::RSA.new(file_fixture_contents('recorder-1.pem'))
    expected_certificate = OpenSSL::X509::Certificate.new(file_fixture_contents('recorder-1.pem'))
    http_request.key.to_s.should == expected_key.to_s
    http_request.cert.to_s.should == expected_certificate.to_s
  end
  
  it "should set the TLS CA file to the underlying request object when passed" do
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {:tls_verify => true, :tls_ca_file => file_fixture('recorder-1.pem') })
    request.perform
    http_request = REST::Request._last_http_request
    
    http_request.ca_file.should == file_fixture('recorder-1.pem')
  end
  
  it "should GET a resource from an HTTPS URL" do
    request = REST::Request.new(:get, URI.parse('https://example.com/resources/1'))
    response = request.perform
    
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should raise an argument error for unknown verbs" do
    request = REST::Request.new(:unknown, URI.parse(''))
    lambda {
      request.perform
    }.should.raise(ArgumentError)
  end
  
  it "should raise a disconnect error when the reading the response fails" do
    begin
      Net::HTTP.start_raises = EOFError.new('failed')
      lambda {
        REST.get('/something')
      }.should.raise(REST::DisconnectedError)
    ensure
      Net::HTTP.start_raises = nil
    end
  end
  
  it "should find http proxy settings from the environment" do
    request = REST::Request.new(:get, URI.parse(''))
    request.http_proxy.should.be.nil
    
    ENV['HTTP_PROXY'] = 'http://localhost'
    request.proxy_env['http'].should. == 'http://localhost'
    ENV.delete('HTTP_PROXY')
    
    ENV['http_proxy'] = 'http://rob:secret@192.168.0.1:21'
    request.proxy_env['http'].should. == 'http://rob:secret@192.168.0.1:21'
    ENV.delete('http_proxy')
  end
  
  it "should find https proxy settings from the environment" do
    request = REST::Request.new(:get, URI.parse(''))
    request.proxy_settings.should.be.nil
    
    ENV['HTTPS_PROXY'] = 'http://localhost'
    request.proxy_env['https'].should. == 'http://localhost'
    ENV.delete('HTTPS_PROXY')
    
    ENV['https_proxy'] = 'http://rob:secret@192.168.0.1:21'
    request.proxy_env['https'].should. == 'http://rob:secret@192.168.0.1:21'
    ENV.delete('https_proxy')
  end
  
  it "parses the http proxy settings" do
    with_env('HTTP_PROXY'=> 'http://rob:secret@192.168.0.1:21') do
      request = REST::Request.new(:get, URI.parse('http://example.com'))
      request.proxy_settings.host.should == '192.168.0.1'
      request.proxy_settings.port.should == 21
      request.proxy_settings.user.should == 'rob'
      request.proxy_settings.password.should == 'secret'
    end
  end
  
  it "parses the https proxy settings" do
    with_env('HTTPS_PROXY'=> 'http://rob:secret@192.168.0.1:21') do
      request = REST::Request.new(:get, URI.parse('https://example.com'))
      request.proxy_settings.host.should == '192.168.0.1'
      request.proxy_settings.port.should == 21
      request.proxy_settings.user.should == 'rob'
      request.proxy_settings.password.should == 'secret'
    end
  end
  
  it "does not return a proxy for any scheme when nothing is configured" do
    request = REST::Request.new(:get, URI.parse('http://example.com/heya'))
    request.http_proxy.should.be.nil
  end
  
  it "does not return a proxy object when a specific scheme is not configured" do
    with_env('HTTP_PROXY'=> 'http://rob:secret@192.168.0.1:21') do
      request = REST::Request.new(:get, URI.parse('https://example.com/heya'))
      request.http_proxy.should.be.nil
    end
  end
  
  it "returns a proxy object when the specific scheme is configured" do
    with_env(
      'HTTP_PROXY'  => 'http://192.168.0.1:80',
      'HTTPS_PROXY' => 'http://192.168.0.2:80'
    ) do
      request = REST::Request.new(:get, URI.parse('http://example.com/heya'))
      request.http_proxy.proxy_address.should == '192.168.0.1'
      
      request = REST::Request.new(:get, URI.parse('https://example.com/heya'))
      request.http_proxy.proxy_address.should == '192.168.0.2'
    end
  end
  
  it "uses the proxy instead of a regular request object when a proxy is configured" do
    request = REST::Request.new(:get, URI.parse('http://example.com/heya'))
    request.http_request.should.be.kind_of?(Net::HTTP)
    request.http_request.proxy_address.should.be.nil
    
    with_env(
      'HTTP_PROXY'  => 'http://192.168.0.1:80',
      'HTTPS_PROXY' => 'http://192.168.0.2:80'
    ) do
      request.http_request.should.be.kind_of?(Net::HTTP)
      request.http_request.proxy_address.should == '192.168.0.1'
    end
  end
  
  it "forwards options when initializing a new request with perform" do
    yielded_http_request = nil
    REST::Request.perform(:get, URI.parse('http://example.com/pigeon')) do |http_request|
      yielded_http_request = http_request
    end
    REST::Request._last_http_request.should == yielded_http_request
  end
  
  it "yields the underlying Net::HTTP request object for additional configuration" do
    yielded_http_request = nil
    request = REST::Request.new(:get, URI.parse('http://example.com/heya')) do |http_request|
      yielded_http_request = http_request
    end
    
    http_request = request.http_request
    http_request.should.not.be.nil
    http_request.should == yielded_http_request
  end
end
