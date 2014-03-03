require File.expand_path('../helper', __FILE__)

describe "REST" do
  before do
    http_response = Net::HTTPOK.new('1.1', '200', 'OK')
    http_response.read_body = 'It works!'
    http_response.add_field('Content-type', 'text/html')
    Net::HTTP.start_returns = http_response
  end
  
  it "should GET a resource" do
    uri = 'http://example.com/resources/1'
    REST.get(uri)
    REST::Request._performed.last.should == [:get, URI.parse(uri), nil, {}, {}]
  end
  
  it "should HEAD a resource" do
    uri = 'http://example.com/resources/1'
    REST.head(uri)
    REST::Request._performed.last.should == [:head, URI.parse(uri), nil, {}, {}]
  end
  
  it "should DELETE a resource" do
    uri = 'http://example.com/resources/1'
    REST.delete(uri)
    REST::Request._performed.last.should == [:delete, URI.parse(uri), nil, {}, {}]
  end
  
  it "should PATCH a resource" do
    uri = 'http://example.com/resources/1'
    body = 'name=Manfred'
    REST.patch(uri, body)
    REST::Request._performed.last.should == [:patch, URI.parse(uri), body, {}, {}]
  end
  
  it "should PUT a resource" do
    uri = 'http://example.com/resources/1'
    body = 'name=Manfred'
    REST.put(uri, body)
    REST::Request._performed.last.should == [:put, URI.parse(uri), body, {}, {}]
  end
  
  it "should POST a resource" do
    uri = 'http://example.com/resources'
    body = 'name=Manfred'
    REST.post(uri, body)
    REST::Request._performed.last.should == [:post, URI.parse(uri), body, {}, {}]
  end
end