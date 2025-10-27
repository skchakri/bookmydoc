class Doctors::DashboardsController < ApplicationController
  before_action :require_doctor

  def show
    @today_appointments = current_user.doctor_appointments.today
                                     .includes(:patient)
                                     .order(scheduled_start: :asc)

    @upcoming_appointments = current_user.doctor_appointments.upcoming
                                        .where('scheduled_start > ?', Time.current.end_of_day)
                                        .limit(5)

    @pending_reviews = TestResultUpload.joins(test_order: :appointment)
                                       .where(appointments: { doctor_id: current_user.id })
                                       .pending_review
                                       .limit(5)

    @unread_notifications = current_user.notifications.unread.recent.limit(5)

    @appointment_slots = current_user.appointment_slots.upcoming.limit(10)

    # Messaging stats
    @unread_messages_count = current_user.unread_messages_count
    @recent_conversations = current_user.conversations
                                       .includes(:avatar_attachment)
                                       .limit(5)
                                       .sort_by { |user| current_user.last_message_with(user)&.created_at || Time.at(0) }
                                       .reverse

    # Payment stats (today)
    @today_payments = calculate_today_payments

    # Availability calendar (next 7 days)
    @availability_calendar = calculate_weekly_availability

    audit_log(action: 'view_doctor_dashboard')
  end

  private

  def calculate_today_payments
    today_start = Time.current.beginning_of_day
    today_end = Time.current.end_of_day

    appointments = current_user.doctor_appointments
                               .where(scheduled_start: today_start..today_end)
                               .where(status: ['completed', 'in_progress'])

    {
      total: appointments.sum(:initial_fee_amount) + appointments.sum(:remaining_fee_amount),
      count: appointments.count
    }
  end

  def calculate_weekly_availability
    start_date = Date.today
    end_date = start_date + 7.days

    unavailable_dates_set = current_user.unavailable_dates
                                        .where(date: start_date..end_date)
                                        .pluck(:date)
                                        .to_set

    booked_dates = current_user.appointment_slots
                               .where('start_time >= ?', start_date.beginning_of_day)
                               .where('start_time <= ?', end_date.end_of_day)
                               .group_by { |slot| slot.start_time.to_date }

    calendar = {}
    (start_date..end_date).each do |date|
      is_weekend = date.wday.in?([0, 6])
      is_unavailable = unavailable_dates_set.include?(date)
      has_slots = booked_dates[date]&.any? { |slot| slot.is_open }

      calendar[date] = {
        available: !is_unavailable && !is_weekend && has_slots,
        is_weekend: is_weekend,
        unavailable: is_unavailable,
        has_slots: has_slots || false
      }
    end

    calendar
  end
end
