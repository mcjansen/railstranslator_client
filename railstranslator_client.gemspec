# frozen_string_literal: true

require_relative "lib/railstranslator_client/version"

Gem::Specification.new do |spec|
  spec.name = "railstranslator_client"
  spec.version = RailstranslatorClient::VERSION
  spec.authors = ["Marco"]
  spec.email = ["marco@example.com"]

  spec.summary = "Rails Engine client for RailsTranslator translation management"
  spec.description = "A Rails Engine that syncs translations from a RailsTranslator server to your Rails application's config/locales directory."
  spec.homepage = "https://github.com/example/railstranslator_client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0"
end
