# frozen_string_literal: true

RailstranslatorClient.configure do |config|
  # Required: Your application's slug in RailsTranslator
  config.app_slug = ENV["RAILSTRANSLATOR_APP_SLUG"]

  # Required: Export API key from your RailsTranslator application settings
  config.api_key = ENV["RAILSTRANSLATOR_API_KEY"]
end
