require File.expand_path('../helper', __FILE__)
require 'rest'

describe "REST Response" do
  it "should initialize without body" do
    lambda {
      REST::Response.new(404)
    }.should.not.raise
  end
  
  it "should respond to all the status code names" do
    response = REST::Response.new(200)
    REST::Response::CODES.all? { |code, name| response.respond_to?("#{name}?") }.should == true
  end
  
  it "should know if the request was a success" do
    response = REST::Response.new(422)
    response.success?.should == false
    
    response = REST::Response.new(201)
    response.success?.should == true
    
    response = REST::Response.new(202)
    response.success?.should == true
  end
  
  it "should have working boolean methods for status codes" do
    response = REST::Response.new(422)
    response.ok?.should == false
    response.not_found?.should == false
    response.unprocessable_entity?.should == true
  end
end