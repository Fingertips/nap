TEST_ROOT = File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../lib', TEST_ROOT)

begin
  require 'rubygems'
rescue
end

require 'test/spec'
require 'mocha'

$:.unshift File.expand_path('lib', TEST_ROOT)

pid = Process.fork
if pid.nil? then
  exec "/usr/bin/env ruby #{File.expand_path('lib/http_server.rb', TEST_ROOT)}"
else
  require 'rest'

  describe "A REST Request" do
    BASE_URL = 'http://localhost:32776'

    it "returns the body of the response" do
      response = REST.get(BASE_URL + '/')
      response.body.should == "OK!\n"
    end

    it "shuts down the server" do
      Process.kill('SIGKILL', pid)
    end
  end
end