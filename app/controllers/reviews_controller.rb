class ReviewsController < ApplicationController
  before_action :require_login
  before_action :require_patient
  before_action :set_doctor

  def create
    @review = current_user.reviews_as_patient.build(review_params)
    @review.doctor = @doctor

    if @review.save
      flash[:notice] = "Thank you for your review!"
      redirect_to doctor_path(@doctor)

      audit_log(action: 'create_review', target: @doctor)
    else
      flash[:alert] = @review.errors.full_messages.join(", ")
      redirect_to doctor_path(@doctor)
    end
  end

  private

  def set_doctor
    @doctor = User.verified_doctors.find(params[:doctor_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def require_patient
    unless current_user&.patient?
      flash[:alert] = "Only patients can write reviews"
      redirect_to root_path
    end
  end
end
