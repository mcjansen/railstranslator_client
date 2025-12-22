# frozen_string_literal: true

RailstranslatorClient.configure do |config|
  # Optional: Override the RailsTranslator server URL (default: https://www.railstranslator.com)
  # Useful for local development/testing
  # config.api_url = "http://localhost:3001"
end

# Required environment variables:
#   RAILSTRANSLATOR_APP_SLUG - Your application's slug in RailsTranslator
#   RAILSTRANSLATOR_API_KEY  - Export API key from your RailsTranslator application settings
