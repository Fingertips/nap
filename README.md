# Nap

> Please don't use Nap in new projects. I know that the net/http looks scary but it's better in the long run to stay closer to Ruby's stdlib. Thanks, and have a nice day 🙂.

Nap is an extremely simple REST client for Ruby. It was built to quickly fire off HTTP requests without having to research net/http internals.

## Example

```ruby
gem 'nap'
require 'rest'
require 'json'

response = REST.get(
  'https://example.com/timelines/friends.json',
  {},
  {:username => '_evan', :password => 'buttonscat'}
)
if response.ok?
  timeline = JSON.parse(response.body)
  puts(timeline.map do |item|
    "#{item['user']['name']}\n\n#{item['text']}"
  end.join("\n\n--\n\n"))
elsif response.forbidden?
  puts "Are you sure you're `_evan' and your password is the name of your cat?"
else
  puts "Something went wrong (#{response.status_code})"
  puts response.body
end
```

## Advanced request configuration

If you need more control over the Net::HTTP request you can pass a block to all of the request methods. 
```ruby
response = REST.get('http://google.com') do |http_request|
  http_request.open_timeout = 15
  http_request.set_debug_output(STDERR)
end
```

## Proxy support

To enable the proxy settings in Nap, you can either use the HTTP\_PROXY or http\_proxy enviroment variable.

    $ env HTTP_PROXY=http://rob:secret@192.167.1.254:665 ruby app.rb

## Exceptions

Nap defines one top-level and three main error types which allow you to catch a whole range of exceptions thrown by underlying protocol implementations.

* *REST::Error*: Any type of error
* *REST::Error::Timeout*: Read timeouts of various sorts
* *REST::Error::Connection*: Connection errors caused by dropped sockets
* *REST::Error::Protocol*: Request failed because of a problem when handling the HTTP request or response

In the most basic case you can rescue from the top-level type to warn about fetching problems.

```ruby
begin
  REST.get('http://example.com/pigeons/12')
rescue REST::Error
  puts "[!] Failed to fetch Pigeon number 12."
end
```

## Contributions

Nap couldn't be the shining beacon in the eternal darkness without help from:

* Eloy Durán
* Joshua Sierles
* Thijs van der Vossen

For all other great human beings, please visit the GitHub contributors page.

## Changes from 1.1.1 to 1.2.0

* We no longer bundle cacert.pem because it's dangerous when it's not updated frequently enough, that's a job for the Ruby distribution or the operating system.
* Changes the default for the `tls_verify:` and `verify_ssl:` options to `true` instead of `false` to make it harder to accidentally make a connection where TLS certs are not verified.
* Modernizes the code a bit to we're sure it runs on Ruby 3.3 and 4.0.

## Changes from 1.1.0 to 1.1.1

* Updated cacert.pem.

## Changes from 1.0.0 to 1.1.0

* REST::Request now allows all HTTP verbs to send a body entity.

## Changes from 0.8.0 to 1.0.0

* Removed REST::DisconnectedError, please use REST::Error::Connection instead.
