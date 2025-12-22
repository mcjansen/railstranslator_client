# frozen_string_literal: true

module RailstranslatorClient
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session

    private

    def check_development_only
      unless Rails.env.development?
        render plain: "RailsTranslator sync routes are only available in development", status: :not_found
      end
    end

    def verify_webhook_secret
      return true if RailstranslatorClient.configuration.webhook_secret.blank?

      provided_secret = request.headers["X-Webhook-Secret"] || params[:secret]
      expected_secret = RailstranslatorClient.configuration.webhook_secret

      unless ActiveSupport::SecurityUtils.secure_compare(provided_secret.to_s, expected_secret.to_s)
        render json: { error: "Unauthorized" }, status: :unauthorized
        false
      end
    end
  end
end
