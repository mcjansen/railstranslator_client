# frozen_string_literal: true

RailstranslatorClient.configure do |config|
  # Required: Your application's slug in RailsTranslator
  config.app_slug = "your-app-slug"

  # Required: Export API key from your RailsTranslator application settings
  config.api_key = "your-api-key"

  # Optional: Override the RailsTranslator server URL (default: https://www.railstranslator.com)
  # Useful for local development/testing
  # config.api_url = "http://localhost:3001"
end
