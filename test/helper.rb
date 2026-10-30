# frozen_string_literal: true

TEST_ROOT = File.expand_path(__dir__)
$LOAD_PATH.unshift File.expand_path('../lib', TEST_ROOT)

require 'rest'

# I'm truly sorry ):
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'bundler/setup'

require 'tmpdir'
require 'fileutils'

$LOAD_PATH.unshift File.expand_path('lib', TEST_ROOT)

require 'http_mock'
require 'rest_mock'
require 'file_fixtures'

require 'peck/flavors/vanilla'

# The once block is ran once when the context is initialized
Peck::Context.once do |_context|
  include Test::FileFixtures

  def with_env(env)
    if ENV.keys.intersect?(env.keys)
      raise ArgumentError, "You can't shadow existing environment variables"
    end

    begin
      env.each { |variable, value| ENV[variable] = value }
      yield
    ensure
      env.each_key { |variable| ENV.delete(variable) }
    end
  end
end
