class Doctors::AppointmentSlotsController < ApplicationController
  before_action :require_doctor
  before_action :set_appointment_slot, only: [:edit, :update, :destroy]

  def index
    @appointment_slots = current_user.appointment_slots.order(start_time: :asc)
                                     .page(params[:page]).per(20)

    audit_log(action: 'view_appointment_slots')
  end

  def new
    @appointment_slot = current_user.appointment_slots.build
  end

  def create
    @appointment_slot = current_user.appointment_slots.build(appointment_slot_params)

    if @appointment_slot.save
      audit_log(action: 'create_appointment_slot', target: @appointment_slot)

      respond_to do |format|
        format.html do
          flash[:notice] = "Availability slot created successfully"
          redirect_to doctors_appointment_slots_path
        end
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment_slot.update(appointment_slot_params)
      audit_log(action: 'update_appointment_slot', target: @appointment_slot)

      respond_to do |format|
        format.html do
          flash[:notice] = "Availability slot updated successfully"
          redirect_to doctors_appointment_slots_path
        end
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment_slot.destroy
    audit_log(action: 'destroy_appointment_slot', target: @appointment_slot)

    respond_to do |format|
      format.html do
        flash[:notice] = "Availability slot deleted successfully"
        redirect_to doctors_appointment_slots_path
      end
      format.turbo_stream
    end
  end

  private

  def set_appointment_slot
    @appointment_slot = current_user.appointment_slots.find(params[:id])
  end

  def appointment_slot_params
    params.require(:appointment_slot).permit(:start_time, :end_time, :frequency_minutes, :is_open)
  end
end
