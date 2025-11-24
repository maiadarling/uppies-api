class ApplicationController < ActionController::API
  before_action :set_default_response_format
  before_action :authenticate_user!

protected

  def current_user
    return nil unless current_user_api_key.present?
    @current_user ||= User.find_by(token: current_user_api_key)
  end

  def logged_in?
    !current_user.nil?
  end

  def authenticate_user!
    return error!("You must be logged in to access this resource") unless current_user_api_key.present?

    user = User.find_by(token: current_user_api_key)

    error!("Access Denied", status: :unauthorized) if user.nil?
  end

  def current_user_api_key
    request.headers["HTTP_X_UPPIES_KEY"] || request.headers["X-UPPIES-KEY"]
  end

  def error!(message, status: :bad_request)
    render json: { error: message }, status: status
  end

  def success!(message = nil, data: nil, template: nil, status: 200, raw: false)
    if raw
      response = { message: message, data: data }
      response.delete(:message) if message.nil?
      render json: response, status: status
      return
    end

    json_data = JbuilderTemplate.new(view_context) do |json|
      if message.present?
        json.message message
      end

      json.data data.nil? ? nil : render_data_object(data, template: template)

      if data.respond_to?(:current_page) && data.respond_to?(:total_pages)
        json.pagination do
          json.page data.current_page
          json.per_page data.per_page
          json.total_pages data.total_pages
          json.total_entries data.total_entries
        end
      end
    end

    render json: json_data.attributes!, status: status
  end

  def render_data_object(data, template: nil, locals: {})
    return nil if data.nil?

    if data.respond_to?(:each)
      return [] if data.empty?

      item = data.first

      template_path = template || "#{params[:controller]}/#{params[:action]}"

      return render_template(template_path, object: data, locals: locals)
    end

    if template.nil?
      if params[:action] == "show"
        template_path = template || "#{params[:controller]}/show"
      else
        template_path = template || "#{params[:controller]}/#{data.class.name.underscore}"
      end
    else
      template_path = template
    end

    render_template(template_path, object: data, locals: locals)
  end

  def render_template(template_path, object:, locals: {})
    JbuilderTemplate.new(view_context) do |json|
      json.partial! template_path, object: object, **locals
    end
  end

private

  def set_default_response_format
    request.format = :json
  end
end
