# frozen_string_literal: true

require_relative "lib/glamour/version"

Gem::Specification.new do |spec|
  spec.name = "glamour"
  spec.version = Glamour::VERSION
  spec.authors = ["Marco Roth"]
  spec.email = ["marco.roth@intergga.ch"]

  spec.summary = "Ruby wrapper for Charm's glamour stylesheet-based markdown rendering for Ruby CLI apps."
  spec.description = spec.summary
  spec.homepage = "https://github.com/marcoroth/glamour-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcoroth/glamour-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/marcoroth/glamour-ruby/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "glamour.gemspec",
    "LICENSE.txt",
    "README.md",
    "lib/**/*.rb",
    "ext/**/*.{c,h,rb}",
    "go/**/*.{go,mod,sum}",
    "go/build/**/*"
  ]

  spec.require_paths = ["lib"]
  spec.extensions = ["ext/glamour/extconf.rb"]
end
