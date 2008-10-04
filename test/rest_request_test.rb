require File.expand_path('../helper', __FILE__)
require 'rest'
require 'uri'

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
    
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should HEAD a resource" do
    request = REST::Request.new(:head, URI.parse('http://example.com/resources/1'))
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
end