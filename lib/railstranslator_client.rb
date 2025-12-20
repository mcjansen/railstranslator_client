# frozen_string_literal: true

require_relative "railstranslator_client/version"
require_relative "railstranslator_client/configuration"
require_relative "railstranslator_client/syncer"
require_relative "railstranslator_client/engine" if defined?(Rails)

module RailstranslatorClient
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class SyncError < Error; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def sync!(locale: nil)
      Syncer.new(configuration).sync!(locale: locale)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
