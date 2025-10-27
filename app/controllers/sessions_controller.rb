class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(phone_number: params[:phone_number])

    if user && user.authenticate(params[:password])
      log_in(user)
      audit_log(action: 'login')

      flash[:notice] = "Welcome back, #{user.full_name}!"

      redirect_to after_login_path(user)
    else
      flash.now[:alert] = "Invalid phone number or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    audit_log(action: 'logout')
    log_out
    flash[:notice] = "You have been logged out successfully"
    redirect_to root_path
  end

  private

  def after_login_path(user)
    case user.role
    when 'patient'
      patients_dashboard_path
    when 'doctor'
      doctors_dashboard_path
    when 'admin'
      admin_dashboard_path
    else
      root_path
    end
  end
end
