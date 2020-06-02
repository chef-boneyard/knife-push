source "https://rubygems.org"

# Specify your gem's dependencies in knife-push.gemspec
gemspec

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

group :test do
  gem "chefstyle"
  gem "rake"
  gem "rspec", "~> 3.0"
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5")
    gem "ohai", "<15"
    gem "chef", "<15"
  else
    gem "ohai"
    gem "chef"
  end
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rb-readline"
end
