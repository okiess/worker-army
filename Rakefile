# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "worker-army"
  gem.homepage = "http://github.com/okiess/worker-army"
  gem.license = "MIT"
  gem.summary = %Q{Simple worker queue}
  gem.description = %Q{Simple redis base worker queue with a HTTP/Rest interface}
  gem.email = "kiessler@inceedo.com"
  gem.authors = ["Oliver Kiessler"]
  gem.add_runtime_dependency 'sinatra'
  gem.add_runtime_dependency 'sinatra-contrib'
  gem.add_runtime_dependency 'rest_client'
  gem.add_runtime_dependency 'redis'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'multi_json'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "worker-army #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
