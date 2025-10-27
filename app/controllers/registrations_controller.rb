class RegistrationsController < ApplicationController
  def new
    @user = User.new
    @role = params[:role] || 'patient'
  end

  def create
    @user = User.new(user_params)
    @role = @user.role

    # Generate and send OTP
    otp_result = OtpService.send_code(@user.phone_number)

    if otp_result[:success]
      @user.phone_otp_code = otp_result[:code]

      if @user.save
        session[:pending_user_id] = @user.id
        flash[:notice] = "Account created! Please verify your phone number. OTP: #{otp_result[:code]}"
        redirect_to verify_otp_path
      else
        render :new, status: :unprocessable_entity
      end
    else
      @user.errors.add(:base, "Failed to send OTP")
      render :new, status: :unprocessable_entity
    end
  end

  def verify_otp
    @user = User.find_by(id: session[:pending_user_id])

    unless @user
      flash[:alert] = "Invalid session"
      redirect_to signup_path and return
    end
  end

  def confirm_otp
    @user = User.find_by(id: session[:pending_user_id])

    unless @user
      flash[:alert] = "Invalid session"
      redirect_to signup_path and return
    end

    if OtpService.verify_code(@user.phone_number, params[:otp_code], @user.phone_otp_code)
      @user.update!(
        phone_verified_at: Time.current,
        phone_otp_code: nil
      )

      session.delete(:pending_user_id)
      log_in(@user)

      flash[:notice] = "Phone verified successfully! Welcome to BookMyDoc."
      redirect_to after_registration_path(@user)
    else
      flash.now[:alert] = "Invalid OTP code"
      render :verify_otp, status: :unprocessable_entity
    end
  end

  private

  def user_params
    permitted = [:full_name, :phone_number, :email, :password, :password_confirmation,
                 :role, :address, :location_city, :location_pin_code, :latitude, :longitude, :avatar]

    # Add doctor-specific fields
    if params[:user][:role] == 'doctor'
      permitted += [:specialization, :years_of_experience, :consultation_fee_initial, :consultation_fee_due,
                    :clinic_address, :about_bio, :medical_registration_number, :aadhaar_number,
                    :profile_photo, :medical_certificate]
    end

    params.require(:user).permit(permitted)
  end

  def after_registration_path(user)
    case user.role
    when 'patient'
      patients_dashboard_path
    when 'doctor'
      doctors_dashboard_path
    else
      root_path
    end
  end
end
