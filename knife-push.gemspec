$:.unshift(File.dirname(__FILE__) + "/lib")
require "knife-push/version"

Gem::Specification.new do |s|
  s.name = "knife-push"
  s.version = Knife::Push::VERSION
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.md", "CONTRIBUTING.md", "LICENSE" ]
  s.summary = "Knife plugin for Chef push"
  s.description = s.summary
  s.license = "Apache-2.0"
  s.author = "John Keiser"
  s.email = "jkeiser@chef.io"
  s.homepage = "https://www.chef.io"

  # We need a more recent version of mixlib-cli in order to support --no- options.
  # ... but, we can live with those options not working, if it means the plugin
  # can be included with apps that have restrictive Gemfile.locks.
  # s.add_dependency "mixlib-cli", ">= 1.2.2"

  s.add_dependency "chef", ">= 12.0"
  s.require_path = "lib"
  s.files = %w{LICENSE README.md Rakefile} + Dir.glob("{lib,spec}/**/*")
  s.required_ruby_version = ">= 2.2.2"
end
