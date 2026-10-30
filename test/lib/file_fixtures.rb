# frozen_string_literal: true

module Test
  module FileFixtures
    def fixture_path
      File.expand_path('../files', __dir__)
    end

    def file_fixture(path, _options = {})
      File.join(fixture_path, path)
    end

    def file_fixture_contents(path, _options = {})
      File.read(file_fixture(path))
    end
  end
end
