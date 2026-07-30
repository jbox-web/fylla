# frozen_string_literal: true

require_relative "lib/fylla/version"

Gem::Specification.new do |spec|
  spec.name = "fylla"
  spec.version = Fylla::VERSION
  spec.authors = ["Tyler Thrailkill"]
  spec.email = ["tyler.b.thrailkill@gmail.com"]

  spec.summary = "Adds functions for generating autocomplete scripts for Thor applications"
  spec.description = "Fylla generates zsh and bash autocomplete scripts for Thor CLI applications."
  spec.homepage = "https://github.com/snowe2010/fylla"
  spec.license = "MIT"

  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.
  spec.metadata["changelog_uri"] = "https://github.com/snowe2010/fylla/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(.idea|test|spec|features)/|^[.][a-zA-Z0-9]|^.*[.]md|Gemfile.lock})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", ">= 0.19.0"
end
