class ApplicationController < ActionController::API
  before_action :authenticate_request!

  private

  def authenticate_request
    header = request.header["Authorization"]
    header = header.split(" ").last if header

    begin
      decoded = JWT.decode(header, ENV["JWT_SECRET_KEY"], true, { algorithm: "HS256" })
      @current_user = User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
