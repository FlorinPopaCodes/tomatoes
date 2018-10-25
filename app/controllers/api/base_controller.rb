module Api
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session

    before_action :set_time_zone

    rescue_from(ActionController::ParameterMissing) do |err|
      render json: { missing_param: err.param }, status: :bad_request
    end

    private

    def current_user
      return unless auth_token

      @current_user ||= User.find_by_token(auth_token)
    end

    def auth_token
      request.headers['Authorization'] || params[:token]
    end

    def authenticate_user!
      unauthorized 'authentication failed' unless current_user
    end

    def unauthorized(reason)
      render status: :unauthorized, json: { error: reason }
    end

    def bad_request(reason)
      render status: :bad_request, json: { error: reason }
    end

    def set_time_zone
      Time.zone = find_time_zone
    rescue ArgumentError => e
      logger.error "Argument error: #{e}"
      Time.zone = Rails.configuration.time_zone
    end

    def find_time_zone
      request.headers['Time-Zone'] ||
        params[:time_zone] ||
        current_user.try(:time_zone)
    end
  end
end
