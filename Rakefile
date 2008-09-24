require 'rake/rdoctask'

desc "Run all specs by default"
task :default => :test

desc "Run all specs"
task :test do
  Dir[File.dirname(__FILE__) + '/test/**/*_test.rb'].each do |file|
    load file
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

namespace :documentation do
  Rake::RDocTask.new(:generate) do |rd|
    rd.main = "README"
    rd.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
    rd.options << "--all" << "--charset" << "utf-8"
  end
end