# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "worker-army"
  s.version = "0.6.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Oliver Kiessler"]
  s.description = "Simple redis based worker queue with a HTTP/Rest interface"
  s.email = "kiessler@inceedo.com"
  s.executables = ["worker_army"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "Gemfile",
    "LICENSE.txt",
    "Procfile",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/worker_army",
    "config.ru",
    "lib/worker-army.rb",
    "lib/worker_army/another_job.rb",
    "lib/worker_army/base.rb",
    "lib/worker_army/client.rb",
    "lib/worker_army/example_job.rb",
    "lib/worker_army/log.rb",
    "lib/worker_army/queue.rb",
    "lib/worker_army/web.rb",
    "lib/worker_army/worker.rb",
    "public/index.html",
    "test/helper.rb",
    "test/test_worker-army.rb",
    "unicorn.rb",
    "worker-army.gemspec",
    "worker_army.yml.sample"
  ]
  s.homepage = "http://github.com/okiess/worker-army"
  s.licenses = ["MIT"]
  s.summary = "Simple worker queue"

  s.add_runtime_dependency "redis"
  s.add_runtime_dependency "multi_json"
  s.add_runtime_dependency "sinatra", ">= 2.2.0"
  s.add_runtime_dependency "sinatra-contrib"
  s.add_runtime_dependency "rest-client", ">= 1.7.3"
  s.add_runtime_dependency "rake", ">= 12.3.3"
  s.add_runtime_dependency "unicorn"
  s.add_runtime_dependency "foreman"

  s.add_development_dependency "bundler", ">= 2.2.33"
  s.add_development_dependency "git", ">= 1.11.0"
  s.add_development_dependency "test-unit", "~> 3.7"
end
