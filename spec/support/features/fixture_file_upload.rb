module Features
  module FixtureFileUpload
    def fixture_file_upload(path, content_type = 'text/plain', binary = false)
      Rack::Test::UploadedFile.new(fixture_file_path(path), content_type, binary)
    end
    def fixture_file(path)
      File.open(fixture_file_path(path))
    end
    def fixture_file_path(path)
      File.join(File.dirname(__FILE__),"..","..","..",'spec','sample_data', path)
    end
  end
end
