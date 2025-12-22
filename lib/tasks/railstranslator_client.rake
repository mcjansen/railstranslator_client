# frozen_string_literal: true

namespace :translations do
  desc "Sync translations from RailsTranslator server"
  task sync: :environment do
    locale = ENV["LOCALE"]

    puts "Syncing translations from RailsTranslator..."
    puts "  API URL: #{RailstranslatorClient.configuration.api_url}"
    puts "  Application: #{RailstranslatorClient.configuration.application}"
    puts "  Locale: #{locale || 'all'}"
    puts

    begin
      results = RailstranslatorClient.sync!(locale: locale)

      if results[:synced].any?
        puts "Successfully synced locales: #{results[:synced].join(', ')}"
      end

      if results[:errors].any?
        puts "Errors:"
        results[:errors].each { |e| puts "  - #{e}" }
        exit 1
      end

      puts "Done!"
    rescue RailstranslatorClient::ConfigurationError => e
      puts "Configuration error: #{e.message}"
      puts
      puts "Please configure RailstranslatorClient in config/initializers/railstranslator.rb:"
      puts
      puts "  RailstranslatorClient.configure do |config|"
      puts "    config.api_url = 'https://your-translator-server.com'"
      puts "    config.api_key = 'your-api-key'"
      puts "    config.application = 'your-application'"
      puts "  end"
      exit 1
    rescue RailstranslatorClient::SyncError => e
      puts "Sync error: #{e.message}"
      exit 1
    end
  end

  desc "Show RailsTranslator client configuration status"
  task status: :environment do
    config = RailstranslatorClient.configuration

    puts "RailstranslatorClient Configuration:"
    puts "  Configured: #{config.valid? ? 'Yes' : 'No'}"
    puts "  API URL: #{config.api_url || '(not set)'}"
    puts "  Application: #{config.application || '(not set)'}"
    puts "  API Key: #{config.api_key.present? ? '(set)' : '(not set)'}"
    puts "  Locales Path: #{config.resolved_locales_path}"
    puts "  Locales: #{config.locales&.join(', ') || '(all)'}"
    puts "  Webhook Secret: #{config.webhook_secret.present? ? '(set)' : '(not set)'}"
  end
end
