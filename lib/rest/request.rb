require 'uri'
require 'net/http'

module REST
  class Request
    attr_accessor :verb, :url, :body, :headers, :options, :request
    
    def initialize(verb, url, body=nil, headers={}, options={})
      @verb = verb
      @url = url
      @body = body
      @headers = headers
      @options = options
    end
    
    def perform
      case verb
      when :get
        self.request = Net::HTTP::Get.new(url.path, headers)
      when :head
        self.request = Net::HTTP::Head.new(url.path, headers)
      when :put
        self.request = Net::HTTP::Put.new(url.path, headers)
        self.request.body = body
      when :post
        self.request = Net::HTTP::Post.new(url.path, headers)
        self.request.body = body
      end
      
      if options[:username] and options[:password]
        request.basic_auth(options[:username], options[:password])
      end
      
      response = Net::HTTP.new(url.host, url.port).start {|http| http.request(request) }
      REST::Response.new(response.code, response.__send__(:instance_variable_get, '@header'), response.body)
    end
    
    def self.perform(*args)
      request = new(*args)
      request.perform
    end
  end
end