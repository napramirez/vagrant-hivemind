require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubygems"
require "bundler/setup"

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r vagrant/hivemind.rb"
end
