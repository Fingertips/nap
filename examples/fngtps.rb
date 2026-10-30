require_relative '../lib/rest'

response = REST.get('https://fngtps.com', {}, { tls_verify: true })
if response.ok?
  match = response.body.match(/<title>([\w]+)<\/title>/)
  if match
    puts match[1]
  end
else
  puts "Failed to fetch the page (#{response.status_code})"
end
