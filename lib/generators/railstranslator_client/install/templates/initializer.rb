# frozen_string_literal: true

RailstranslatorClient.configure do |config|
  # Required: URL of your RailsTranslator server
  config.api_url = ENV["RAILSTRANSLATOR_URL"]

  # Required: Export API key from your RailsTranslator application settings
  config.api_key = ENV["RAILSTRANSLATOR_API_KEY"]

  # Required: Your application's slug in RailsTranslator
  config.app_slug = ENV["RAILSTRANSLATOR_APP_SLUG"]

  # Optional: Path where locale files will be written
  # Default: Rails.root.join("config/locales")
  # config.locales_path = Rails.root.join("config/locales/synced")

  # Optional: Specific locales to sync (default: all available)
  # config.locales = [:nl, :en, :fr, :de]

  # Optional: Secret for webhook authentication
  # Set this to secure the /railstranslator/sync endpoint
  # config.webhook_secret = ENV["RAILSTRANSLATOR_WEBHOOK_SECRET"]
end
