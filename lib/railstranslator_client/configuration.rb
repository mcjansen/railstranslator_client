# frozen_string_literal: true

module RailstranslatorClient
  class Configuration
    attr_accessor :api_url, :api_key, :app_slug, :locales_path, :locales, :webhook_secret

    def initialize
      @api_url = ENV["RAILSTRANSLATOR_URL"]
      @api_key = ENV["RAILSTRANSLATOR_API_KEY"]
      @app_slug = ENV["RAILSTRANSLATOR_APP_SLUG"]
      @locales_path = nil # Will default to Rails.root.join("config/locales") in engine
      @locales = nil # nil means all available locales
      @webhook_secret = ENV["RAILSTRANSLATOR_WEBHOOK_SECRET"]
    end

    def valid?
      api_url.present? && api_key.present? && app_slug.present?
    end

    def validate!
      errors = []
      errors << "api_url is required" if api_url.blank?
      errors << "api_key is required" if api_key.blank?
      errors << "app_slug is required" if app_slug.blank?

      raise ConfigurationError, errors.join(", ") if errors.any?
    end

    def resolved_locales_path
      @locales_path || Rails.root.join("config", "locales")
    end
  end
end
