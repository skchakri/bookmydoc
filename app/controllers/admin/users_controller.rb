class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy, :verify]

  def index
    @users = User.all

    # Filter by role
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end

    # Filter by verification status
    if params[:verified].present?
      @users = @users.where(is_verified: params[:verified] == 'true')
    end

    # Search
    if params[:search].present?
      @users = @users.where("full_name ILIKE ? OR phone_number ILIKE ? OR email ILIKE ?",
                           "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @users = @users.order(created_at: :desc).page(params[:page]).per(20)

    audit_log(action: 'view_users_admin')
  end

  def show
    @appointments = if @user.patient?
      @user.patient_appointments
    elsif @user.doctor?
      @user.doctor_appointments
    else
      []
    end

    @appointments = @appointments.order(scheduled_start: :desc).limit(10)

    audit_log(action: 'view_user_admin', target: @user)
  end

  def new
    @user = User.new(role: params[:role] || 'patient')
  end

  def create
    @user = User.new(user_params)
    @user.password = SecureRandom.hex(8) if @user.password.blank?

    if @user.save
      audit_log(action: 'create_user_admin', target: @user)

      flash[:notice] = "User created successfully"
      redirect_to admin_user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      audit_log(action: 'update_user_admin', target: @user)

      flash[:notice] = "User updated successfully"
      redirect_to admin_user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    audit_log(action: 'destroy_user_admin', target: @user)

    flash[:notice] = "User deleted successfully"
    redirect_to admin_users_path
  end

  def verify
    @user.verify!
    audit_log(action: 'verify_user_admin', target: @user)

    respond_to do |format|
      format.html do
        flash[:notice] = "User verified successfully"
        redirect_to admin_user_path(@user)
      end
      format.turbo_stream
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = [:full_name, :phone_number, :email, :password, :password_confirmation,
                 :role, :location_city, :location_pin_code, :latitude, :longitude,
                 :is_verified, :avatar]

    # Add doctor-specific fields
    if params[:user][:role] == 'doctor' || @user&.doctor?
      permitted += [:specialization, :consultation_fee_initial, :consultation_fee_due,
                    :clinic_address, :about_bio, :medical_registration_number, :aadhaar_number]
    end

    params.require(:user).permit(permitted)
  end
end
