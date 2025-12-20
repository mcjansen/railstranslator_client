# frozen_string_literal: true

require "net/http"
require "json"
require "yaml"
require "fileutils"

module RailstranslatorClient
  class Syncer
    attr_reader :config, :results

    def initialize(config)
      @config = config
      @results = { synced: [], errors: [] }
    end

    def sync!(locale: nil)
      config.validate!

      locales_to_sync = determine_locales(locale)

      locales_to_sync.each do |loc|
        sync_locale(loc)
      end

      reload_translations! if results[:synced].any?

      results
    end

    private

    def determine_locales(locale)
      if locale
        [locale.to_s]
      elsif config.locales.present?
        Array(config.locales).map(&:to_s)
      else
        # Fetch available locales from server
        fetch_available_locales
      end
    end

    def fetch_available_locales
      # Default to common locales if we can't determine from server
      # In a real implementation, you might want to add an endpoint to list available locales
      %w[nl en fr de]
    end

    def sync_locale(locale)
      Rails.logger.info "[RailstranslatorClient] Syncing locale: #{locale}"

      translations = fetch_translations(locale)

      if translations
        write_locale_file(locale, translations)
        results[:synced] << locale
        Rails.logger.info "[RailstranslatorClient] Successfully synced #{locale}"
      end
    rescue StandardError => e
      error_message = "Failed to sync #{locale}: #{e.message}"
      results[:errors] << error_message
      Rails.logger.error "[RailstranslatorClient] #{error_message}"
    end

    def fetch_translations(locale)
      uri = build_uri(locale)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{config.api_key}"
      request["Accept"] = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPNotFound
        Rails.logger.warn "[RailstranslatorClient] Locale #{locale} not found on server"
        nil
      else
        raise SyncError, "HTTP #{response.code}: #{response.message}"
      end
    end

    def build_uri(locale)
      base_url = config.api_url.chomp("/")
      URI.parse("#{base_url}/api/v1/#{config.app_slug}/translations/#{locale}")
    end

    def write_locale_file(locale, translations)
      FileUtils.mkdir_p(config.resolved_locales_path)

      file_path = File.join(config.resolved_locales_path, "#{locale}.yml")

      # Wrap translations in locale key if not already wrapped
      data = if translations.keys == [locale.to_s]
               translations
             else
               { locale.to_s => translations }
             end

      File.write(file_path, data.to_yaml)

      Rails.logger.info "[RailstranslatorClient] Wrote translations to #{file_path}"
    end

    def reload_translations!
      I18n.reload!
      Rails.logger.info "[RailstranslatorClient] Reloaded I18n translations"
    end
  end
end
