class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    permitted_params = %i[first_name last_name age date_of_birth email password password_confirmation]
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(permitted_params) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(permitted_params, :current_password) }
  end

  def authenticate_admin!
    token = Token.find_by(value: request.headers['Authorization'])
    if token.nil? || token.expired_at < Time.current
      render json: { error: 'Unauthorized access' }, status: :unauthorized
    end
  end

  def authenticate_case_manager!
    authenticate_user!
    redirect_to root_path, alert: 'Unauthorized access' unless current_user.case_manager?
  end

  def authenticate_dispute_analyst!
    authenticate_user!
    redirect_to root_path, alert: 'Unauthorized access' unless current_user.dispute_analyst?
  end

end
