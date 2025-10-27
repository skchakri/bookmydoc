class Admin::AppointmentsController < ApplicationController
  before_action :require_admin

  def index
    @appointments = Appointment.includes(:doctor, :patient)

    # Filter by status
    if params[:status].present?
      @appointments = @appointments.where(status: params[:status])
    end

    @appointments = @appointments.order(scheduled_start: :desc)
                                 .page(params[:page]).per(20)

    audit_log(action: 'view_appointments_admin')
  end

  def show
    @appointment = Appointment.find(params[:id])
    @test_orders = @appointment.test_orders.includes(:test_result_uploads)

    audit_log(action: 'view_appointment_admin', target: @appointment)
  end
end
