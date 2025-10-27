class TestOrdersController < ApplicationController
  before_action :require_login
  before_action :set_test_order, only: [:show]

  def index
    @test_orders = if current_patient?
      current_user.test_orders_as_patient
    elsif current_doctor?
      current_user.test_orders_as_doctor
    elsif current_admin?
      TestOrder.all
    else
      TestOrder.none
    end

    @test_orders = @test_orders.includes(:appointment, :doctor, :patient, :test_result_uploads)
                               .order(created_at: :desc)
                               .page(params[:page]).per(20)

    audit_log(action: 'view_test_orders')
  end

  def show
    unless can_view_test_order?
      flash[:alert] = "Access denied"
      redirect_to root_path and return
    end

    @test_result_uploads = @test_order.test_result_uploads.includes(:file_attachment)

    audit_log(action: 'view_test_order', target: @test_order)
  end

  def create
    unless current_doctor?
      flash[:alert] = "Only doctors can create test orders"
      redirect_to root_path and return
    end

    @appointment = Appointment.find(params[:test_order][:appointment_id])
    @test_order = @appointment.test_orders.build(test_order_params)
    @test_order.doctor = current_user
    @test_order.patient = @appointment.patient

    if @test_order.save
      audit_log(action: 'create_test_order', target: @test_order)

      respond_to do |format|
        format.html do
          flash[:notice] = "Test order created successfully"
          redirect_to @appointment
        end
        format.turbo_stream
      end
    else
      flash[:alert] = "Failed to create test order"
      redirect_to @appointment
    end
  end

  private

  def set_test_order
    @test_order = TestOrder.find(params[:id])
  end

  def test_order_params
    params.require(:test_order).permit(:description, :message_to_patient)
  end

  def can_view_test_order?
    current_admin? ||
      (@test_order.patient == current_user) ||
      (@test_order.doctor == current_user)
  end
end
