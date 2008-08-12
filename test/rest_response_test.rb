require File.expand_path('../helper', __FILE__)
require 'rest'

describe "REST Response" do
  it "should initialize without body" do
    lambda {
      REST::Response.new(404)
    }.should.not.raise
  end
end