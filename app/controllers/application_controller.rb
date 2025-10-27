class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :current_patient?, :current_doctor?, :current_admin?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def current_patient?
    logged_in? && current_user.patient?
  end

  def current_doctor?
    logged_in? && current_user.doctor?
  end

  def current_admin?
    logged_in? && current_user.admin?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    end
  end

  def require_patient
    unless current_patient?
      flash[:alert] = "Access denied. Patients only."
      redirect_to root_path
    end
  end

  def require_doctor
    unless current_doctor?
      flash[:alert] = "Access denied. Doctors only."
      redirect_to root_path
    end
  end

  def require_admin
    unless current_admin?
      flash[:alert] = "Access denied. Admins only."
      redirect_to root_path
    end
  end

  def log_in(user)
    session[:user_id] = user.id
    user.update(last_login_at: Time.current)
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def audit_log(action:, target: nil)
    AuditLog.log(user: current_user, action: action, target: target) if logged_in?
  end
end
