require File.expand_path('../helper', __FILE__)
require 'rest'
require 'json'
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
    body = {'example' => true}.to_json
    request = REST::Request.new(:put, URI.parse('http://example.com/resources/1'), body)
    
    response = request.perform
    request.request.body.should == body
    
    response.status_code.should == 200
    response.body.should == 'It works!'
  end
  
  it "should POST a resource" do
    body = {'example' => true}.to_json
    request = REST::Request.new(:post, URI.parse('http://example.com/resources'), body)
    
    response = request.perform
    request.request.body.should == body
    
    response.status_code.should == 200
    response.body.should == 'It works!'    
  end
  
  it "should move the response headers to the REST::Response object" do
    request = REST::Request.new(:get, URI.parse('http://example.com/resources/1'))
    response = request.perform
    response.headers['content-type'].should == ['text/html']
  end
end