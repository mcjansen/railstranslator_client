# frozen_string_literal: true

module RailstranslatorClient
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a RailstranslatorClient initializer and mounts the engine"

      def copy_initializer
        template "initializer.rb", "config/initializers/railstranslator.rb"
      end

      def mount_engine
        route 'mount RailstranslatorClient::Engine => "/railstranslator"'
      end

      def show_readme
        say ""
        say "RailstranslatorClient installed!", :green
        say ""
        say "Next steps:"
        say "  1. Configure your settings in config/initializers/railstranslator.rb"
        say "  2. Set the required environment variables:"
        say "     - RAILSTRANSLATOR_URL"
        say "     - RAILSTRANSLATOR_API_KEY"
        say "     - RAILSTRANSLATOR_APP_SLUG"
        say "  3. Run 'rake translations:sync' to sync translations"
        say ""
      end
    end
  end
end
