class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers["Authorization"]
    if header.nil?
      render json: { error: "Authorization header missing" }, status: :unauthorized
      return
    end

    token = header.split(" ").last

    begin
      decoded = JWT.decode(token, Rails.application.credentials.fetch(:jwt_secret_key), true, { algorithm: "HS256" })
      @current_user = User.find(decoded[0]["sub"])
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    rescue StandardError => e
      render json: { error: "Authentication error: #{e.message}" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
