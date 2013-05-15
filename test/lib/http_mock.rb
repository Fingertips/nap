require 'net/http'

module Net
  class HTTPOK
    attr_accessor :read_body
  end

  class HTTP
    class TryingToMakeHTTPConnectionException < StandardError; end

    def connect
      raise TryingToMakeHTTPConnectionException, "Please mock your HTTP calls so you don't do any HTTP requests."
    end

    class << self
      attr_accessor :start_returns, :start_raises, :expects
    end

    def start
      if self.class.start_raises
        raise self.class.start_raises
      else
        self.class.start_returns
      end
    end
  end
end