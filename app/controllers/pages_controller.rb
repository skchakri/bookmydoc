class PagesController < ApplicationController
  def home
    if logged_in?
      redirect_to case current_user.role
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
end
