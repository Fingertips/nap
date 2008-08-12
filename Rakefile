desc "Run all specs by default"
task :default => :test

desc "Run all specs"
task :test do
  Dir[File.dirname(__FILE__) + '/test/**/*_test.rb'].each do |file|
    load file
  end
end