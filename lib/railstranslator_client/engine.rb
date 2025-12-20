# frozen_string_literal: true

module RailstranslatorClient
  class Engine < ::Rails::Engine
    isolate_namespace RailstranslatorClient

    initializer "railstranslator_client.add_locales" do |app|
      # Ensure our synced locales directory is in the load path
      config = RailstranslatorClient.configuration
      if config.locales_path.present?
        app.config.i18n.load_path += Dir[File.join(config.locales_path, "*.yml")]
      end
    end

    # Load rake tasks
    rake_tasks do
      load "tasks/railstranslator_client.rake"
    end
  end
end
