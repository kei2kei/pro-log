class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_unread_notifications_count
  helper_method :compared_product_ids, :compare_full?

  unless Rails.env.development? || Rails.env.test?
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::InvalidAuthenticityToken, with: :render_422
    rescue_from StandardError, with: :render_500
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :avatar ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :avatar ])
  end

  def compared_product_ids
    session[:compare_product_ids] ||= []
  end

  def compare_full?
    compared_product_ids.size >= 3
  end

  private

  def set_unread_notifications_count
    return unless user_signed_in?

    @unread_notifications_count = current_user.received_notifications.unread.count
  end

  def render_404
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def render_422
    render file: Rails.root.join("public/422.html"), status: :unprocessable_content, layout: false
  end

  def render_500
    render file: Rails.root.join("public/500.html"), status: :internal_server_error, layout: false
  end
end
