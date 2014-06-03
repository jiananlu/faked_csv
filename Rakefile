require "bundler/gem_tasks"
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

task :default => [:spec, :cucumber]

Cucumber::Rake::Task.new() do |t|
  t.cucumber_opts = "features --format pretty"
end

RSpec::Core::RakeTask.new(:spec)

task :clean do
  sh "rm -rf tmp"
end
