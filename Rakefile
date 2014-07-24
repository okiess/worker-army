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
  gem.name = "worker-army"
  gem.homepage = "http://github.com/okiess/worker-army"
  gem.license = "MIT"
  gem.summary = %Q{Simple worker queue}
  gem.description = %Q{Simple redis based worker queue with a HTTP/Rest interface}
  gem.email = "kiessler@inceedo.com"
  gem.authors = ["Oliver Kiessler"]
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

require File.dirname(__FILE__) + '/lib/worker-army'
task 'start_example_workers' do
  WorkerArmy::Worker.new([ExampleJob.new, AnotherJob.new]).process_queue
end

desc "Start a worker-army worker to execute job classes"
task :start_worker, :job_classes do |t|
  ARGV.shift
  if ARGV and ARGV.size > 0
    clazzes = []
    ARGV.each do |jc|
      clazzes << Object.const_get(jc.lstrip.rstrip).new
    end
    WorkerArmy::Worker.new(clazzes).process_queue
  end
end
