class TestResultUploadsController < ApplicationController
  before_action :require_login
  before_action :set_test_result_upload, only: [:show, :review]

  def new
    @test_order = params[:test_order_id].present? ? TestOrder.find(params[:test_order_id]) : nil
    @test_result_upload = TestResultUpload.new(test_order: @test_order)

    unless current_patient?
      flash[:alert] = "Only patients can upload test results"
      redirect_to root_path and return
    end
  end

  def create
    @test_result_upload = TestResultUpload.new(test_result_upload_params)
    @test_result_upload.uploaded_by_patient = current_user

    if @test_result_upload.save
      audit_log(action: 'upload_test_result', target: @test_result_upload)

      respond_to do |format|
        format.html do
          flash[:notice] = "Test result uploaded successfully"
          redirect_to test_result_upload_path(@test_result_upload)
        end
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    unless can_view_test_result?
      flash[:alert] = "Access denied"
      redirect_to root_path and return
    end

    audit_log(action: 'view_test_result', target: @test_result_upload)
  end

  def review
    unless current_doctor? || current_admin?
      flash[:alert] = "Only doctors can review test results"
      redirect_to @test_result_upload and return
    end

    if @test_result_upload.review_by!(current_user, params[:doctor_comments])
      audit_log(action: 'review_test_result', target: @test_result_upload)

      # Notify patient
      Notification.create!(
        user: @test_result_upload.uploaded_by_patient,
        title: "Test Result Reviewed",
        body: "Dr. #{current_user.full_name} has reviewed your test results",
        metadata: { test_result_upload_id: @test_result_upload.id, action: 'reviewed' }
      )

      respond_to do |format|
        format.html do
          flash[:notice] = "Review submitted successfully"
          redirect_to @test_result_upload
        end
        format.turbo_stream
      end
    else
      flash[:alert] = "Failed to submit review"
      redirect_to @test_result_upload
    end
  end

  private

  def set_test_result_upload
    @test_result_upload = TestResultUpload.find(params[:id])
  end

  def test_result_upload_params
    params.require(:test_result_upload).permit(:test_order_id, :file, :notes_from_patient)
  end

  def can_view_test_result?
    current_admin? ||
      (@test_result_upload.uploaded_by_patient == current_user) ||
      (current_doctor? && has_appointment_with_patient?)
  end

  def has_appointment_with_patient?
    Appointment.where(
      doctor: current_user,
      patient: @test_result_upload.uploaded_by_patient
    ).exists?
  end
end
