# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: worker-army 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "worker-army"
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Oliver Kiessler"]
  s.date = "2014-06-05"
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
    "Gemfile.lock",
    "LICENSE.txt",
    "Procfile",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/worker_army",
    "config.ru",
    "lib/worker-army.rb",
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
  s.rubygems_version = "2.2.2"
  s.summary = "Simple worker queue"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra-contrib>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<unicorn>, [">= 0"])
      s.add_runtime_dependency(%q<foreman>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6.2"])
    else
      s.add_dependency(%q<redis>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<sinatra-contrib>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<unicorn>, [">= 0"])
      s.add_dependency(%q<foreman>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<bundler>, ["~> 1.6.2"])
    end
  else
    s.add_dependency(%q<redis>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<sinatra-contrib>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<unicorn>, [">= 0"])
    s.add_dependency(%q<foreman>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<bundler>, ["~> 1.6.2"])
  end
end

