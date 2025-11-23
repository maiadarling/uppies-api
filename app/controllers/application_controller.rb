class ApplicationController < ActionController::API
  before_action :set_default_response_format
  before_action :authenticate_user!

protected

  def current_user
    return nil unless session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def authenticate_user!
    return error!("You must be logged in to access this resource") unless current_user_api_key.present?

    user = User.find_by(token: current_user_api_key)

    return error!("Access Denied", status: :unauthorized) if user.nil?
  end

  def current_user_api_key
    request.headers['X-Uppies-Key']
  end

  def success!(message = nil, data: nil, template: nil, status: :ok)
    render json: { message: message, data: data }, status: status
  end

  def error!(message, status: :bad_request)
    render json: { error: message }, status: status
  end

private

  def set_default_response_format
    request.format = :json
  end
end
