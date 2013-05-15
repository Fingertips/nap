require 'rake/testtask'

desc "Run all specs by default"
task :default => :test

desc "Run all specs"
task :test => ['test:unit', 'test:functional']

namespace :test do
  Rake::TestTask.new('unit') do |t|
    t.test_files = FileList['test/rest*_test.rb']
    t.verbose = true
  end
  
  Rake::TestTask.new('functional') do |t|
    t.test_files = FileList['test/functional_test.rb']
    t.verbose = true
  end
end

namespace :gem do
  desc "Build the gem"
  task :build do
    sh 'gem build nap.gemspec'
  end
  
  task :install => :build do
    sh 'sudo gem install nap-*.gem'
  end
end

begin
  require 'rdoc/task'
rescue LoadError
end

begin
  require 'rake/rdoctask'
rescue
end

if defined?(Rake::RDocTask)
  namespace :documentation do
    Rake::RDocTask.new(:generate) do |rd|
      rd.main = "README"
      rd.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
      rd.options << "--all" << "--charset" << "utf-8"
    end
  end
end