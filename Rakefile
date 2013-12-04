require './worker'
require "resque/tasks"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end
