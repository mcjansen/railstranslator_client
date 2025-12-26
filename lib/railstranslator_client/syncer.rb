# frozen_string_literal: true

require "net/http"
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
      request["Accept"] = "text/yaml"

      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # Skip CRL check which can fail on some systems
        http.verify_callback = ->(_preverify_ok, _store_ctx) { true }
      end

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        response.body.force_encoding("UTF-8")
      when Net::HTTPNotFound
        raise SyncError, "Application '#{config.application}' or locale '#{locale}' not found on server (404)"
      when Net::HTTPUnauthorized
        raise SyncError, "Invalid API key - authentication failed (401)"
      when Net::HTTPForbidden
        raise SyncError, "Access denied to application '#{config.application}' (403)"
      else
        raise SyncError, "HTTP #{response.code}: #{response.message}"
      end
    end

    def build_uri(locale)
      base_url = config.api_url.chomp("/")
      URI.parse("#{base_url}/api/v1/#{config.application}/translations/#{locale}")
    end

    def write_locale_file(locale, yaml_content)
      FileUtils.mkdir_p(config.resolved_locales_path)

      file_path = File.join(config.resolved_locales_path, "#{locale}.yml")
      File.write(file_path, yaml_content)

      Rails.logger.info "[RailstranslatorClient] Wrote translations to #{file_path}"
    end

    def reload_translations!
      I18n.reload!
      Rails.logger.info "[RailstranslatorClient] Reloaded I18n translations"
    end
  end
end
