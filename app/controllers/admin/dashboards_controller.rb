class Admin::DashboardsController < ApplicationController
  before_action :require_admin

  def show
    @total_patients = User.patient.count
    @total_doctors = User.doctor.count
    @verified_doctors = User.verified_doctors.count
    @unverified_doctors = User.doctor.where(is_verified: false).count

    @total_appointments = Appointment.count
    @pending_appointments = Appointment.pending_payment.count
    @confirmed_appointments = Appointment.confirmed.count
    @completed_appointments = Appointment.completed.count

    @recent_symptom_reports = SymptomReport.order(created_at: :desc).limit(10)
    @recent_appointments = Appointment.order(created_at: :desc).limit(10)

    @unverified_doctors_list = User.doctor.where(is_verified: false)
                                   .order(created_at: :desc)
                                   .limit(10)

    audit_log(action: 'view_admin_dashboard')
  end
end
