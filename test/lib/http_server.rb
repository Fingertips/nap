require 'socket'

class Webserver
  PORT = 32776
  REQUEST_LINE = /^(GET)\s+([^\s]+)\s+HTTP\/1\.1\s*$/
  CODES_AND_PHRASES = {
    :ok                    => '200 OK',
    :not_found             => '404 Not Found',
    :internal_server_error => '500 Internal Server Error'
  }
  
  def status_line(name)
    if code_and_phrase = CODES_AND_PHRASES[name]
      "HTTP/1.1 #{code_and_phrase}"
    else
      raise ArgumentError, "Unknown status `#{name}'"
    end
  end
  
  def response(client, status, body)
    client.puts status_line(status)
    client.puts "Content-Type: text/plain"
    client.puts "\r\n"
    client.puts body
  end
  
  def run
    server = TCPServer.new(PORT)
    puts "Webserver running on #{PORT}"
    loop do
      Thread.start(server.accept) do |client|
        begin
          request_line = client.gets
          if match = REQUEST_LINE.match(request_line)
            verb = match[1]
            path = match[2]
          
            log("#{verb} #{path}")
          
            case path
            when '/'
              response(client, :ok, 'OK!')
            when '/disconnect'
              client.close
            else
              response(client, :not_found, "Unknown path: #{path}")
            end
          else
            response(client, :internal_server_error, "Invalid request line")
          end
        rescue => e
          response(client, :internal_server_error, [e.message, e.backtrace.join("\n")].join("\n"))
        end
        client.close
      end
    end
    puts "Webserver shutting down"
  end
  
  def log(message)
    puts "#{Time.now.to_s} #{message}"
  end
  
  def self.run
    new.run
  end
end


if ARGV[0] == 'test'
  require 'test/unit'
  
  class WebserverTest < Test::Unit::TestCase
    def test_request_regexp
      match = Webserver::REQUEST_LINE.match("GET / HTTP/1.1\r\n")
      assert_equal '/', match[2]
    end
  end
elsif __FILE__ == $0
  Webserver.run
end