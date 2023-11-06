# frozen_string_literal: true

require_relative "lib/strings/truncation/version"

Gem::Specification.new do |spec|
  spec.name          = "strings-truncation"
  spec.version       = Strings::Truncation::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = "Truncate strings with fullwidth characters and ANSI codes."
  spec.description   = "Truncate strings with fullwidth characters and ANSI codes. Characters can be omitted from the start, middle, end or both ends."
  spec.homepage      = "https://github.com/piotrmurach/strings-truncation"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/strings-truncation/issues"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/strings-truncation/blob/master/CHANGELOG.md"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/strings-truncation"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["rubygems_mfa_required"] = "true"
  end

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "strings-ansi",          "~> 0.2.0"
  spec.add_dependency "unicode-display_width", ">= 1.6", "< 3.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
