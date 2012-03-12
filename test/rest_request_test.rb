require File.expand_path('../helper', __FILE__)
require 'rest'
require 'uri'
require 'openssl'

describe "A REST Request" do
  before do
    http_response = Net::HTTPOK.new('1.1', '200', 'OK')
    http_response.stubs(:read_body).returns('It works!')
    http_response.add_field('Content-type', 'text/html')
    Net::HTTP.any_instance.stubs(:start).returns(http_response)
  end
  
  it "should GET a resource" do
    request = REST::Request.new(:get, URI.parse('http://example.com/resources/1'))
    response = request.perform
    
    request.request.path.should == '/resources/1'
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
    
    post = mock()
    post.expects(:body=).with(body)
    Net::HTTP::Post.stubs(:new).with(request.url.path, {}).returns(post)
    
    request.perform
  end
  
  it "should move headers to the underlying request object" do
    headers = {'Accepts' => 'text/html', 'X-Helo' => 'Hi there!'}
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), '', headers)
    Net::HTTP::Post.expects(:new).with(request.url.path, headers).returns(stub(:body= => ''))
    request.perform
  end
  
  it "should move the response headers to the REST::Response object" do
    request = REST::Request.new(:get, URI.parse('http://example.com/resources/1'))
    response = request.perform
    response.headers['content-type'].should == ['text/html']
  end
  
  it "should move basic authentication credentials to the underlying request object" do
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), '', {}, {:username => 'admin', :password => 'secret'})
    Net::HTTP::Post.any_instance.expects(:basic_auth).with('admin', 'secret')
    request.perform
  end
  
  it "should set the proper attributes for checking the server certificate during a TLS connection" do
    http_request = Net::HTTP.new('example.com')
    if http_request.respond_to?(:enable_post_connection_check=)
      http_request.expects(:enable_post_connection_check=).with(true)
    end
    http_request.expects(:ca_file=).with(File.expand_path('../../support/cacert.pem', __FILE__))
    http_request.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
    Net::HTTP.expects(:new).returns(http_request)
    
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {:tls_verify => true})
    request.perform
  end
  
  it "should set TLS key ad certificate to the underlying request object" do
    key = OpenSSL::PKey::RSA.new(file_fixture_contents('recorder-1.pem'))
    certificate = OpenSSL::X509::Certificate.new(file_fixture_contents('recorder-1.pem'))
    
    http_request = Net::HTTP.new('example.com')
    http_request.expects(:key=).with(key)
    Net::HTTP.expects(:new).returns(http_request)
    
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {
      :tls_key => key,
      :tls_certificate => certificate
    })
    request.perform
  end
  
  it "should set TLS key and certificate to the underlying request object when passed a key file" do
    http_request = Net::HTTP.new('example.com')
    Net::HTTP.expects(:new).returns(http_request)
    
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {:tls_key_and_certificate_file => file_fixture('recorder-1.pem') })
    request.perform
    
    expected_key = OpenSSL::PKey::RSA.new(file_fixture_contents('recorder-1.pem'))
    expected_certificate = OpenSSL::X509::Certificate.new(file_fixture_contents('recorder-1.pem'))
    http_request.key.to_s.should == expected_key.to_s
    http_request.cert.to_s.should == expected_certificate.to_s
  end
  
  it "should set the TLS CA file to the underlying request object when passed" do
    http_request = Net::HTTP.new('example.com')
    Net::HTTP.expects(:new).returns(http_request)
    
    request = REST::Request.new(:get, URI.parse('https://example.com/resources'), '', {}, {:tls_verify => true, :tls_ca_file => file_fixture('recorder-1.pem') })
    request.perform
    
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
  
  it "should raise a disconnect errro when the reading the response fails" do
    http_request = Net::HTTP.new('example.com')
    Net::HTTP.expects(:new).returns(http_request)
    http_request.expects(:start).raises(EOFError.new('failed'))
    lambda {
      REST.get('/something')
    }.should.raise(REST::DisconnectedError)
  end
  
  it "should find proxy settings from the environment" do
    request = REST::Request.new(:get, URI.parse(''))
    request.http_proxy.should.be.nil
    
    ENV['HTTP_PROXY'] = 'http://localhost'
    request.http_proxy.should. == 'http://localhost'
    ENV.delete('HTTP_PROXY')
    
    ENV['http_proxy'] = 'http://rob:secret@192.168.0.1:21'
    request.http_proxy.should. == 'http://rob:secret@192.168.0.1:21'
    ENV.delete('http_proxy')
  end
  
  it "parses the http proxy settings" do
    request = REST::Request.new(:get, URI.parse(''))
    request.stubs(:http_proxy).returns('http://rob:secret@192.168.0.1:21')
    request.proxy_settings.host.should == '192.168.0.1'
    request.proxy_settings.port.should == 21
    request.proxy_settings.user.should == 'rob'
    request.proxy_settings.password.should == 'secret'
  end
  
  it "should use a proxy when the http_proxy" do
    request = REST::Request.new(:get, URI.parse(''))
    request.http_request.should.be.kind_of?(Net::HTTP)
    request.http_request.proxy_address.should.be.nil
    
    request.stubs(:http_proxy).returns('http://192.168.0.1:80')
    request.http_request.should.be.kind_of?(Net::HTTP)
    request.http_request.proxy_address.should == '192.168.0.1'
  end
end