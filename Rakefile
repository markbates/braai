require 'bundler'  
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:default) do |t|
  t.libs << "spec"
  t.pattern = "spec/**/*_spec.rb"
end