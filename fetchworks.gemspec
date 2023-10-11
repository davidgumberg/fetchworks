# frozen_string_literal: true

require_relative "lib/fetchworks/version"

Gem::Specification.new do |spec|
  spec.name = "fetchworks"
  spec.version = Fetchworks::VERSION
  spec.authors = ["David Gumberg"]
  spec.email = ["davidzgumberg@gmail.com"]

  spec.summary = "A simple gem for programmatic access of data about written works."
  spec.description = "A simple gem for programmatic access of data about written works.
                      At present, it has support for the OpenLibrary API"

  spec.homepage = "https://github.com/davidgumberg/fetchworks"
  spec.required_ruby_version = ">= 3.0"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/davidgumberg/fetchworks"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "open-uri"
  spec.add_dependency "petrarca", "~> 0.5"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "standard"
end
