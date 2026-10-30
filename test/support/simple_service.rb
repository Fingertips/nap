# frozen_string_literal: true

require 'socket'

# Speaks just enough HTTP over a plain socket to be able to disconnect in the middle of a request.
class SimpleService
  HOST = '127.0.0.1'
  PORT = 32_776
  REQUEST_LINE = %r{^(GET)\s+([^\s]+)\s+HTTP/1\.1\s*$}
  CODES_AND_PHRASES = {
    ok: '200 OK',
    not_found: '404 Not Found',
    internal_server_error: '500 Internal Server Error'
  }.freeze

  def run
    server = TCPServer.new(HOST, PORT)
    loop do
      Thread.start(server.accept) { |client| handle(client) }
    end
  end

  def self.run
    new.run
  end

  private

  def handle(client)
    if (match = REQUEST_LINE.match(client.gets))
      route(client, match[2])
    else
      respond(client, :internal_server_error, 'Invalid request line')
    end
  rescue StandardError => e
    respond(client, :internal_server_error, [e.message, e.backtrace.join("\n")].join("\n"))
  ensure
    client.close
  end

  def route(client, path)
    case path
    when '/'
      respond(client, :ok, 'OK!')
    when '/disconnect'
      client.close
    else
      respond(client, :not_found, "Unknown path: #{path}")
    end
  end

  def respond(client, status, body)
    client.puts "HTTP/1.1 #{CODES_AND_PHRASES.fetch(status)}"
    client.puts 'Content-Type: text/plain'
    client.puts "\r\n"
    client.puts body
  end
end

SimpleService.run if __FILE__ == $PROGRAM_NAME
