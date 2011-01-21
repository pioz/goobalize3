# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "goobalize3/version"

Gem::Specification.new do |s|
  s.name        = "goobalize3"
  s.version     = Goobalize3::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Enrico Pilotto"]
  s.email       = ["enrico@megiston.it"]
  s.homepage    = ""
  s.summary     = %q{Auto translate with Google Translate the Globalize3 attributes}
  s.description = s.summary
  s.add_dependency('globalize3')


  s.rubyforge_project = "goobalize3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
