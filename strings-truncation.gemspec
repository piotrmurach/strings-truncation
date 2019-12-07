lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "strings/truncation/version"

Gem::Specification.new do |spec|
  spec.name          = "strings-truncation"
  spec.version       = Strings::Truncation::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["me@piotrmurach.com"]

  spec.summary       = %q{Truncate strings with multibyte chars and ansi codes}
  spec.description   = %q{Truncate strings with multibyte chars and ansi codes}
  spec.homepage      = "https://github.com/piotrmurach/strings-truncation"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/strings-truncation/blob/master/CHANGELOG.md"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/strings-truncation"
    spec.metadata["homepage_uri"] = spec.homepage
  end

  spec.files         = Dir["{spec,lib}/**/*.rb"]
  spec.files        += Dir["tasks/*", "strings-truncation.gemspec"]
  spec.files        += Dir["README.md", "CHANGELOG.md", "LICENSE.txt", "Rakefile"]
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "strings-ansi",          "~> 0.2"
  spec.add_dependency "unicode-display_width", "~> 1.6"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
