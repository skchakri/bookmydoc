class AppointmentsController < ApplicationController
  before_action :require_login
  before_action :set_appointment, only: [:show, :update, :payment_confirm]

  def index
    @appointments = if current_patient?
      current_user.patient_appointments
    elsif current_doctor?
      current_user.doctor_appointments
    elsif current_admin?
      Appointment.all
    else
      Appointment.none
    end

    @appointments = case params[:filter]
    when 'upcoming'
      @appointments.upcoming
    when 'past'
      @appointments.past
    when 'today'
      @appointments.today
    else
      @appointments.order(scheduled_start: :desc)
    end

    @appointments = @appointments.includes(:doctor, :patient)
                                 .page(params[:page]).per(20)

    audit_log(action: 'view_appointments')
  end

  def show
    # Security check
    unless can_view_appointment?
      flash[:alert] = "Access denied"
      redirect_to root_path and return
    end

    audit_log(action: 'view_appointment', target: @appointment)
  end

  def new
    @doctor = User.verified_doctors.find(params[:doctor_id])
    @appointment = Appointment.new(doctor: @doctor)

    unless current_patient?
      flash[:alert] = "Only patients can book appointments"
      redirect_to doctor_path(@doctor) and return
    end

    @available_slots = upcoming_available_slots(@doctor)
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.patient = current_user
    @appointment.status = :pending_payment
    @appointment.initial_fee_amount = @appointment.doctor.consultation_fee_initial
    @appointment.remaining_fee_amount = @appointment.doctor.consultation_fee_due

    if @appointment.save
      audit_log(action: 'create_appointment', target: @appointment)

      flash[:notice] = "Appointment created. Please complete payment to confirm."
      redirect_to payment_confirm_appointment_path(@appointment)
    else
      @doctor = @appointment.doctor
      @available_slots = upcoming_available_slots(@doctor)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless can_manage_appointment?
      flash[:alert] = "Access denied"
      redirect_to @appointment and return
    end

    if params[:action_type] == 'reschedule' && current_doctor?
      handle_reschedule
    elsif params[:action_type] == 'complete' && current_doctor?
      handle_complete
    elsif params[:action_type] == 'cancel'
      handle_cancel
    else
      handle_update
    end
  end

  def payment_confirm
    unless can_view_appointment?
      flash[:alert] = "Access denied"
      redirect_to root_path and return
    end

    if @appointment.pending_payment?
      # Process payment
      payment_result = PaymentService.initiate_partial_payment(@appointment, method: :upi)

      if payment_result[:success]
        @appointment.confirm_payment!
        audit_log(action: 'confirm_payment', target: @appointment)

        flash[:notice] = "Payment successful! Your appointment is confirmed."
        redirect_to @appointment
      else
        flash[:alert] = "Payment failed. Please try again."
        render :payment_confirm, status: :unprocessable_entity
      end
    else
      redirect_to @appointment
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:doctor_id, :scheduled_start, :scheduled_end, :patient_notes)
  end

  def can_view_appointment?
    current_admin? ||
      (@appointment.patient == current_user) ||
      (@appointment.doctor == current_user)
  end

  def can_manage_appointment?
    current_admin? || (@appointment.doctor == current_user)
  end

  def handle_reschedule
    new_start = params[:appointment][:scheduled_start]
    new_end = params[:appointment][:scheduled_end]

    if @appointment.reschedule!(new_start, new_end)
      audit_log(action: 'reschedule_appointment', target: @appointment)

      respond_to do |format|
        format.html do
          flash[:notice] = "Appointment rescheduled successfully"
          redirect_to @appointment
        end
        format.turbo_stream
      end
    else
      flash[:alert] = "Failed to reschedule appointment"
      redirect_to @appointment
    end
  end

  def handle_complete
    if @appointment.update(appointment_update_params.merge(status: :completed))
      audit_log(action: 'complete_appointment', target: @appointment)

      flash[:notice] = "Appointment marked as completed"
      redirect_to @appointment
    else
      flash[:alert] = "Failed to update appointment"
      redirect_to @appointment
    end
  end

  def handle_cancel
    if @appointment.update(status: :cancelled)
      audit_log(action: 'cancel_appointment', target: @appointment)

      flash[:notice] = "Appointment cancelled"
      redirect_to appointments_path
    else
      flash[:alert] = "Failed to cancel appointment"
      redirect_to @appointment
    end
  end

  def handle_update
    if @appointment.update(appointment_update_params)
      audit_log(action: 'update_appointment', target: @appointment)

      flash[:notice] = "Appointment updated successfully"
      redirect_to @appointment
    else
      flash[:alert] = "Failed to update appointment"
      render :show, status: :unprocessable_entity
    end
  end

  def appointment_update_params
    if current_doctor?
      params.require(:appointment).permit(:doctor_notes, :audio_recording_url, :screenshot_attachment)
    else
      params.require(:appointment).permit(:patient_notes)
    end
  end

  def upcoming_available_slots(doctor)
    slots = doctor.appointment_slots
                  .open
                  .where('start_time >= ? AND start_time <= ?', Time.current, 7.days.from_now)
                  .order(:start_time)

    available_times = []
    slots.each do |slot|
      available_times.concat(slot.generate_available_times)
    end

    available_times.sort_by { |t| t[:start] }.first(20)
  end
end
