# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "resque-exception-mailer"
  s.version     = "0.1"
  s.authors     = ["Shaun Mangelsdorf"]
  s.email       = ["s.mangelsdorf@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Send email notifications when a Resque job fails}
  s.description = %q{Resque plugin to handle exceptions by sending an email notification}

  s.rubyforge_project = "resque-exception-mailer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "jars"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", '~> 2.8.0'
  # s.add_runtime_dependency "rest-client"
end
