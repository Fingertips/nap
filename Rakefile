# frozen_string_literal: true

require 'rake/testtask'

task default: :test

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
