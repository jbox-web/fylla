# frozen_string_literal: true

require_relative "lib/fylla/version"

Gem::Specification.new do |s|
  s.name        = "fylla"
  s.version     = Fylla::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tyler Thrailkill"]
  s.email       = ["tyler.b.thrailkill@gmail.com"]
  s.homepage    = "https://github.com/jbox-web/fylla"
  s.summary     = "Adds functions for generating autocomplete scripts for Thor applications"
  s.description = "Fylla generates zsh and bash autocomplete scripts for Thor CLI applications."
  s.license     = "MIT"
  s.metadata    = {
    "homepage_uri"    => "https://github.com/jbox-web/fylla",
    "changelog_uri"   => "https://github.com/jbox-web/fylla/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/jbox-web/fylla",
    "bug_tracker_uri" => "https://github.com/jbox-web/fylla/issues",
  }

  s.required_ruby_version = ">= 3.2.0"

  s.files = Dir["README.md", "CHANGELOG.md", "LICENSE", "lib/**/*.rb", "lib/**/*.erb", "exe/*"]

  s.bindir      = "exe"
  s.executables = ["fylla"]

  s.add_dependency "thor", ">= 0.19.0"
end
