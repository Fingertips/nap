TEST_ROOT = File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../lib', TEST_ROOT)

require 'rest'

# I'm truly sorry ):
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'bundler/setup'

require 'tmpdir'
require 'fileutils'

$:.unshift File.expand_path('lib', TEST_ROOT)

require 'http_mock'
require 'rest_mock'
require 'file_fixtures'

require 'peck/flavors/vanilla'

# The once block is ran once when the context is initialized
Peck::Context.once do |context|
  include Test::FileFixtures
  
  def with_env(env)
    unless (ENV.keys & env.keys).empty?
      raise ArgumentError, "You can't shadow existing environment variables"
    end
    
    begin
      env.each { |variable, value| ENV[variable] = value }
      yield
    ensure
      env.each { |variable, value| ENV.delete(variable) }
    end
  end
end