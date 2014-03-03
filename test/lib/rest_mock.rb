module PerformLogger
end

module REST
  class Request
    class << self
      attr_accessor :_performed, :_last_http_request
      
      alias _perform perform
    end
    
    def self.perform(*args, &configure_block)
      REST::Request._performed ||= []
      REST::Request._performed << args
      _perform(*args, &configure_block)
    end
    
    alias _http_request http_request
    
    def http_request
      self.class._last_http_request = _http_request
    end
  end
end