# Nap

Nap is an extremely simple REST client for Ruby. It was built to quickly
fire off HTTP requests without having to research net/http internals.

## Example

    gem 'nap'
    require 'rest'
    require 'json'
    
    response = REST.get('http://twitter.com/statuses/friends_timeline.json', {},
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

## Advanced request configuration

If you need more control over the Net::HTTP request you can pass a block to
all of the request methods. 

    response = REST.get('http://google.com') do |http_request|
      http_request.open_timeout = 15
      http_request.set_debug_output(STDERR)
    end

## Proxy support

To enable the proxy settings in Nap, you can either use the HTTP\_PROXY or http\_proxy enviroment variable.

    $ env HTTP_PROXY=http://rob:secret@192.167.1.254:665 ruby app.rb

## Contributions

Nap couldn't be the shining beacon in the eternal darkness without help from:

* Eloy Durán
* Joshua Sierles
* Thijs van der Vossen