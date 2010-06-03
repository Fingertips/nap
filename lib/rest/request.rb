require 'uri'
require 'net/http'

module REST
  # Request holds a HTTP request
  class Request
    attr_accessor :verb, :url, :body, :headers, :options, :request
    
    # * <tt>verb</tt>: The verb to use in the request, either :get, :head, :put, or :post
    # * <tt>url</tt>: The URL to send the request to, must be a URI instance
    # * <tt>body</tt>: The body to use in the request
    # * <tt>headers</tt>: A hash of headers to add to the request
    # * <tt>options</tt>: A hash of additional options
    #   * <tt>username</tt>: Username to use for basic authentication
    #   * <tt>password</tt>: Password to use for basic authentication
    #   * <tt>tls_verify/verify_ssl</tt>: Verify the server certificate against known CA's
    #   * <tt>tls_ca_file</tt>: Use a specific file for CA certificates instead of the built-in one
    #     this only works when <tt>:tls_verify</tt> is also set.
    #   * <tt>tls_key_and_certificate_file</tt>: The client key and certificate file to use for this request
    #   * <tt>tls_certificate</tt>: The client certficate to use for this request
    #   * <tt>tls_key</tt>: The client private key to use for this request
    #
    # == Examples
    #
    #   request = REST::Request.new(:get, URI.parse('http://example.com/pigeons/1'))
    #
    #   request = REST::Request.new(:head, URI.parse('http://example.com/pigeons/1'))
    #
    #   request = REST::Request.new(:post,
    #     URI.parse('http://example.com/pigeons'),
    #     {'name' => 'Homr'}.to_json,
    #     {'Accept' => 'application/json, */*', 'Content-Type' => 'application/json; charset=utf-8'}
    #   )
    #
    # == Authentication example
    #
    #   request = REST::Request.new(:put,
    #     URI.parse('http://example.com/pigeons/1'),
    #     {'name' => 'Homer'}.to_json,
    #     {'Accept' => 'application/json, */*', 'Content-Type' => 'application/json; charset=utf-8'},
    #     {:username => 'Admin', :password => 'secret'}
    #   )
    #
    # == TLS / SSL examples
    #
    #   # Use a client key and certificate
    #   request = REST::Request.new(:get, URI.parse('https://example.com/pigeons/1'), {}, {}, {
    #     :tls_key_and_certificate_file => '/home/alice/keys/example.pem'
    #   })
    #
    #   # Use a client certificate and key from a specific location
    #   key_and_certificate = File.read('/home/alice/keys/example.pem')
    #   request = REST::Request.new(:get, URI.parse('https://example.com/pigeons/1'), {}, {}, {
    #     :tls_key => OpenSSL::PKey::RSA.new(key_and_certificate),
    #     :tls_certificate => OpenSSL::X509::Certificate.new(key_and_certificate)
    #   })
    #
    #   # Verify the server certificate against a specific certificate
    #   request = REST::Request.new(:get, URI.parse('https://example.com/pigeons/1'), {}, {}, {
    #     :tls_verify => true,
    #     :tls_ca_file => '/home/alice/keys/example.pem'
    #   })
    def initialize(verb, url, body=nil, headers={}, options={})
      @verb = verb
      @url = url
      @body = body
      @headers = headers
      @options = options
    end
    
    # Returns the path (including the query) for the request
    def path
      [url.path, url.query].compact.join('?')
    end
    
    # Performs the actual request and returns a REST::Response object with the response
    def perform
      case verb
      when :get
        self.request = Net::HTTP::Get.new(path, headers)
      when :head
        self.request = Net::HTTP::Head.new(path, headers)
      when :delete
        self.request = Net::HTTP::Delete.new(path, headers)
      when :put
        self.request = Net::HTTP::Put.new(path, headers)
        self.request.body = body
      when :post
        self.request = Net::HTTP::Post.new(path, headers)
        self.request.body = body
      else
        raise ArgumentError, "Unknown HTTP verb `#{verb}'"
      end
      
      if options[:username] and options[:password]
        request.basic_auth(options[:username], options[:password])
      end
            
      http_request = Net::HTTP.new(url.host, url.port)
      
      # enable SSL/TLS
      if url.scheme == 'https'
        require 'net/https'
        require 'openssl'
        
        http_request.use_ssl = true
        
        if options[:tls_verify] or options[:verify_ssl]
          if http_request.respond_to?(:enable_post_connection_check=)
            http_request.enable_post_connection_check = true
          end
          # from http://curl.haxx.se/ca/cacert.pem
          http_request.ca_file = options[:tls_ca_file] || File.join(File.expand_path('../../../support/cacert.pem', __FILE__))
          http_request.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          http_request.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        
        if options[:tls_key_and_certificate_file]
          key_and_certificate       = File.read(options[:tls_key_and_certificate_file])
          options[:tls_key]         = OpenSSL::PKey::RSA.new(key_and_certificate)
          options[:tls_certificate] = OpenSSL::X509::Certificate.new(key_and_certificate)
        end
        
        if options[:tls_key] and options[:tls_certificate]
          http_request.key  = options[:tls_key]
          http_request.cert = options[:tls_certificate]
        elsif options[:tls_key] || options[:tls_certificate]
          raise ArgumentError, "Please specify both the certificate and private key (:tls_key and :tls_certificate)"
        end
      end
      
      response = http_request.start { |http| http.request(request) }
      REST::Response.new(response.code, response.instance_variable_get('@header'), response.body)
    end
    
    # Shortcut for REST::Request.new(*args).perform.
    #
    # See new for options.
    def self.perform(*args)
      request = new(*args)
      request.perform
    end
  end
end