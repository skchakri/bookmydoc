class DoctorsController < ApplicationController
  before_action :require_login, except: [:index, :show]

  def index
    @doctors = User.verified_doctors.includes(:avatar_attachment)

    # Filter by specialization
    if params[:specialization].present?
      @doctors = @doctors.by_specialization(params[:specialization])
    end

    # Search by name
    if params[:search].present?
      @doctors = @doctors.where("full_name ILIKE ?", "%#{params[:search]}%")
    end

    # Sort by distance if patient is logged in with location
    if current_patient? && current_user.latitude && current_user.longitude
      @doctors = @doctors.nearby(current_user.latitude, current_user.longitude)
    end

    @doctors = @doctors.order(:full_name).page(params[:page]).per(12)

    audit_log(action: 'search_doctors') if logged_in?
  end

  def show
    @doctor = User.verified_doctors.find_by!(slug: params[:slug])

    @distance = if current_patient? && current_user.latitude && current_user.longitude
      current_user.distance_to(@doctor)
    end

    @available_slots = upcoming_available_slots(@doctor)

    # Get awards and unavailable dates
    @awards = @doctor.awards.recent_first.limit(10)
    @unavailable_dates = @doctor.unavailable_dates.upcoming

    # Calculate availability calendar for next 60 days
    @availability_calendar = calculate_availability_calendar

    # Get reviews
    @reviews = @doctor.reviews_as_doctor.recent.includes(:patient).limit(10)
    @average_rating = @doctor.average_rating
    @total_reviews = @doctor.total_reviews
    @user_has_reviewed = current_patient? && current_user.has_reviewed?(@doctor)

    # Generate QR code for doctor profile
    require 'rqrcode'
    qr_url = doctor_url(@doctor)
    @qr_code = RQRCode::QRCode.new(qr_url)

    audit_log(action: 'view_doctor_profile', target: @doctor) if logged_in?
  end

  private

  def upcoming_available_slots(doctor)
    # Get next 7 days of slots
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

  def calculate_availability_calendar
    start_date = Date.today
    end_date = start_date + 60.days

    unavailable_dates_set = @doctor.unavailable_dates
                                    .where(date: start_date..end_date)
                                    .pluck(:date)
                                    .to_set

    # Get appointment slots
    booked_dates = @doctor.appointment_slots
                           .where('start_time >= ?', start_date.beginning_of_day)
                           .where('start_time <= ?', end_date.end_of_day)
                           .group_by { |slot| slot.start_time.to_date }

    calendar = {}
    (start_date..end_date).each do |date|
      is_weekend = date.wday.in?([0, 6])  # Sunday or Saturday
      is_unavailable = unavailable_dates_set.include?(date)
      has_slots = booked_dates[date]&.any? { |slot| slot.is_open }

      calendar[date] = {
        available: !is_unavailable && !is_weekend && date > Date.today && has_slots,
        is_weekend: is_weekend,
        unavailable: is_unavailable,
        has_slots: has_slots || false
      }
    end

    calendar
  end
end
