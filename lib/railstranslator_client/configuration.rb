# frozen_string_literal: true

module RailstranslatorClient
  class Configuration
    # Default server URL (production)
    DEFAULT_API_URL = "https://www.railstranslator.com"

    attr_accessor :api_url, :api_key, :app_slug, :locales_path, :locales, :webhook_secret

    # Backwards compatibility alias for old config files using `application`
    alias_method :application=, :app_slug=
    alias_method :application, :app_slug

    def initialize
      @api_url = ENV["RAILSTRANSLATOR_URL"] || DEFAULT_API_URL
      @api_key = ENV["RAILSTRANSLATOR_API_KEY"]
      @app_slug = ENV["RAILSTRANSLATOR_APP_SLUG"]
      @locales_path = nil # Will default to Rails.root.join("config/locales") in engine
      @locales = nil # nil means all available locales
      @webhook_secret = ENV["RAILSTRANSLATOR_WEBHOOK_SECRET"]
    end

    def valid?
      api_key.present? && app_slug.present?
    end

    def validate!
      errors = []
      errors << "api_key is required" if api_key.blank?
      errors << "app_slug is required" if app_slug.blank?

      raise ConfigurationError, errors.join(", ") if errors.any?
    end

    def resolved_locales_path
      @locales_path || Rails.root.join("config", "locales")
    end

    # Build the return URL for redirecting back to RailsTranslator after sync
    def return_url
      "#{api_url}/#{app_slug}"
    end
  end
end
