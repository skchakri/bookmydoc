module Doctors
  class ProfilesController < ApplicationController
    before_action :require_login
    before_action :require_doctor
    before_action :set_doctor

    def edit
      @doctor = current_user
    end

    def update
      @doctor = current_user

      # Process certificates and awards
      if params[:certificates].present?
        certificates_data = params[:certificates].reject { |c| c[:name].blank? }
        @doctor.certificates = certificates_data.to_json
      end

      if params[:awards].present?
        awards_data = params[:awards].reject { |a| a[:title].blank? }
        @doctor.awards = awards_data.to_json
      end

      if @doctor.update(doctor_params)
        flash[:notice] = 'Profile updated successfully'
        redirect_to doctors_dashboard_path
      else
        flash[:alert] = 'Failed to update profile'
        render :edit
      end
    end

    private

    def set_doctor
      @doctor = current_user
      unless @doctor.doctor?
        flash[:alert] = 'Only doctors can access this page'
        redirect_to root_path
      end
    end

    def require_doctor
      unless current_user&.doctor?
        flash[:alert] = 'Access denied'
        redirect_to root_path
      end
    end

    def doctor_params
      params.require(:user).permit(
        :full_name,
        :email,
        :phone_number,
        :address,
        :location_city,
        :location_pin_code,
        :specialization,
        :years_of_experience,
        :medical_registration_number,
        :consultation_fee_initial,
        :consultation_fee_due,
        :bio,
        :clinic_address,
        :avatar,
        :profile_photo,
        :medical_certificate
      )
    end
  end
end
