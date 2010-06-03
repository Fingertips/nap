module Test
  module FileFixtures
    def fixture_path
      File.expand_path('../../files', __FILE__)
    end
    
    def file_fixture(path, options={})
      File.join(fixture_path, path)
    end
    
    def file_fixture_contents(path, options={})
      File.read(file_fixture(path))
    end
  end
end