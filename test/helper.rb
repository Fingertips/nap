TEST_ROOT = File.expand_path('../', __FILE__)
$:.unshift File.expand_path('../lib', TEST_ROOT)

begin
  require 'rubygems'
rescue
end

require 'test/spec'
require 'mocha'

require 'tmpdir'
require 'fileutils'

$:.unshift File.expand_path('lib', TEST_ROOT)

require 'http_mock'
require 'file_fixtures'

module Test::Spec::TestCase::InstanceMethods
  include Test::FileFixtures
end
