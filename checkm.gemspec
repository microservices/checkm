# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), "lib/checkm/version")

Gem::Specification.new do |s|
  s.name = %q{checkm}
  s.version = Checkm::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Beer"]
  s.date = %q{2011-06-09}
  s.email = %q{chris@cbeer.info}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Bundler will install these gems too if you've checked this out from source from git and run 'bundle install'
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'rcov'
  s.add_development_dependency 'yard'
end

