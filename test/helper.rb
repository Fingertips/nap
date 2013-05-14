TEST_ROOT = File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../lib', TEST_ROOT)

# I'm truly sorry ):
require 'rubygems'
require 'bundler/setup'

require 'tmpdir'
require 'fileutils'

$:.unshift File.expand_path('lib', TEST_ROOT)

require 'http_mock'
require 'file_fixtures'

if RUBY_VERSION < "2.0.0"
  require 'test/spec'
  module Test::Spec::TestCase::InstanceMethods
    include Test::FileFixtures
  end
else
  require 'peck/flavors/vanilla'
end