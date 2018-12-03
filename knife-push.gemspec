$:.unshift(File.dirname(__FILE__) + "/lib")
require "knife-push/version"

Gem::Specification.new do |s|
  s.name = "knife-push"
  s.version = Knife::Push::VERSION
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.summary = "Knife plugin for Chef push"
  s.description = s.summary
  s.license = "Apache-2.0"
  s.author = "John Keiser"
  s.email = "jkeiser@chef.io"
  s.homepage = "https://www.chef.io"

  s.add_dependency "chef", ">= 13.0"
  s.require_path = "lib"
  s.files = %w{LICENSE README.md Rakefile} + Dir.glob("{lib,spec}/**/*")
  s.required_ruby_version = ">= 2.2.2"
end
