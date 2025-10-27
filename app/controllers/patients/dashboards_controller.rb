class Patients::DashboardsController < ApplicationController
  before_action :require_patient

  def show
    @upcoming_appointments = current_user.patient_appointments.upcoming.limit(5)
    @recent_test_results = current_user.test_result_uploads.order(created_at: :desc).limit(3)
    @unread_notifications = current_user.notifications.unread.recent.limit(5)
    @last_visited_doctor = current_user.last_visited_doctor

    audit_log(action: 'view_patient_dashboard')
  end
end
