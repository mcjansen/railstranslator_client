# frozen_string_literal: true

module RailstranslatorClient
  class SyncController < ApplicationController
    before_action :check_development_only
    before_action :verify_webhook_secret, only: [:create]
    skip_before_action :verify_authenticity_token, only: [:create]

    # GET /railstranslator/sync
    # Shows a page that triggers sync via JavaScript (for browser-based sync)
    def show
      @config = RailstranslatorClient.configuration
      @locale = params[:locale]
      @auto_sync = params[:auto] == "true"
      @return_url = @config.return_url
    end

    # POST /railstranslator/sync
    # Triggered by webhook from RailsTranslator server or manually
    def create
      locale = params[:locale]

      begin
        results = RailstranslatorClient.sync!(locale: locale)

        respond_to do |format|
          format.html { redirect_to railstranslator_client.sync_path, notice: "Synced: #{results[:synced].join(', ')}" }
          format.json do
            if results[:errors].any?
              render json: {
                success: false,
                synced: results[:synced],
                errors: results[:errors]
              }, status: :unprocessable_entity
            else
              render json: {
                success: true,
                synced: results[:synced],
                message: "Translations synced successfully"
              }
            end
          end
        end
      rescue RailstranslatorClient::ConfigurationError => e
        respond_to do |format|
          format.html { redirect_to railstranslator_client.sync_path, alert: "Configuration error: #{e.message}" }
          format.json { render json: { success: false, error: "Configuration error: #{e.message}" }, status: :unprocessable_entity }
        end
      rescue RailstranslatorClient::SyncError => e
        respond_to do |format|
          format.html { redirect_to railstranslator_client.sync_path, alert: "Sync error: #{e.message}" }
          format.json { render json: { success: false, error: "Sync error: #{e.message}" }, status: :unprocessable_entity }
        end
      end
    end

    # GET /railstranslator/status
    # Check configuration status
    def status
      config = RailstranslatorClient.configuration

      render json: {
        configured: config.valid?,
        api_url: config.api_url.present? ? config.api_url.gsub(/\/\/.*@/, "//***@") : nil,
        app_slug: config.app_slug,
        locales_path: config.resolved_locales_path.to_s,
        webhook_protected: config.webhook_secret.present?
      }
    end
  end
end
