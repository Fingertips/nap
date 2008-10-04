require File.expand_path('../helper', __FILE__)
require 'rest'
require 'uri'

describe "REST" do
  it "should GET a resource" do
    uri = 'http://example.com/resources/1'
    REST::Request.expects(:perform).with(:get, URI.parse(uri), nil, {}, {})
    REST.get(uri)
  end
  
  it "should HEAD a resource" do
    uri = 'http://example.com/resources/1'
    REST::Request.expects(:perform).with(:head, URI.parse(uri), nil, {}, {})
    REST.head(uri)
  end
  
  it "should PUT a resource" do
    uri = 'http://example.com/resources/1'
    body = 'name=Manfred'
    REST::Request.expects(:perform).with(:put, URI.parse(uri), body, {}, {})
    REST.put(uri, body)
  end
  
  it "should POST a resource" do
    uri = 'http://example.com/resources'
    body = 'name=Manfred'
    REST::Request.expects(:perform).with(:post, URI.parse(uri), body, {}, {})
    REST.post(uri, body)
  end
end