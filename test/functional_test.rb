TEST_ROOT = File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', TEST_ROOT)

pid = Process.fork
if pid.nil?
  exec "/usr/bin/env ruby #{File.expand_path('lib/http_server.rb', TEST_ROOT)}"
else
  require 'rest'
  
  require 'rubygems' if RUBY_VERSION < '1.9.0'
  
  require 'peck'
  require 'peck/delegates'
  require 'peck/counter'
  require 'peck/context'
  require 'peck/specification'
  require 'peck/expectations'
  require 'peck/notifiers/default'
  
  class FunctionalNotifier < Peck::Notifiers::Default
    def finished_specification(spec)
    end
  end
  
  notifier = FunctionalNotifier.new
  Peck.delegates << notifier
  
  at_exit do
    Peck.run
    Process.kill('SIGKILL', pid)
    notifier.write_stats
  end
  
  describe "A remote REST Request" do
    BASE_URL = 'http://localhost:32776'
    
    it "returns the body of the response" do
      response = REST.get(BASE_URL + '/')
      response.body.should == "OK!\n"
    end
    
    it "does stuff when the server disconnects" do
      begin
        REST.get(BASE_URL + '/disconnect')
      rescue REST::DisconnectedError => e
        e.message.should == 'end of file reached'
      else
        fail
      end
    end
  end
end

