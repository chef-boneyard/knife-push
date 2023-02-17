$:.unshift(File.dirname(__FILE__) + "/lib")
require "knife-push/version"

Gem::Specification.new do |s|
  s.name = "knife-push"
  s.version = Knife::Push::VERSION
  s.summary = "Knife plugin for Chef Push Jobs"
  s.description = s.summary
  s.license = "Apache-2.0"
  s.author = "John Keiser"
  s.email = "jkeiser@chef.io"
  s.homepage = "https://github.com/chef/knife-push/"

  s.add_dependency "chef", ">= 15.0"
  s.add_dependency "addressable"
  s.require_path = "lib"
  s.files = %w{LICENSE} + Dir.glob("{lib}/**/*")
  s.required_ruby_version = ">= 2.5"
end
