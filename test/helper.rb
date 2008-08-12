TEST_ROOT = File.expand_path('../', __FILE__)

$:.unshift File.expand_path('../lib', TEST_ROOT)

require 'rubygems' rescue LoadError

require 'test/spec'
require 'mocha'

require 'tmpdir'
require 'fileutils'

$:.unshift File.expand_path('lib', TEST_ROOT)

require 'http_mock'