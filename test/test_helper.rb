# frozen_string_literal: true

GEM_ROOT = File.expand_path('..', __dir__)
TEST_ROOT = __dir__
FILES_ROOT = "#{TEST_ROOT}/files".freeze
SUPPORT_ROOT = "#{TEST_ROOT}/support".freeze

require 'minitest/autorun'
require 'webmock/minitest'

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'rest'

module REST
  class Test < Minitest::Test
    def self.test(description, &)
      define_method("test_#{description}", &)
    end

    private

    def fixture_file(path)
      File.join(FILES_ROOT, path)
    end

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
end
