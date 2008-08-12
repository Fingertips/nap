module REST
  class Response
    CODES = [
      [200, :ok],
      [301, :moved_permanently],
      [302, :found],
      [400, :bad_request],
      [401, :unauthorized],
      [403, :forbidden],
      [422, :unprocessable_entity],
      [404, :not_found],
      [500, :internal_server_error]
    ]
    
    attr_accessor :body, :headers, :status_code
    
    def initialize(status_code, headers={}, body='')
      @status_code = status_code.to_i
      @headers = headers
      @body = body
    end
    
    CODES.each do |code, name|
      define_method "#{name}?" do
        status_code == code
      end
    end
    
    def success?
      (status_code.to_s =~ /2../) ? true : false
    end
  end
end