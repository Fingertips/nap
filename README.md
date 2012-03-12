= Nap

It be an extremely simple REST library, yo!

== Example

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