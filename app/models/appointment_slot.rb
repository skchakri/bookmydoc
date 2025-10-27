class AppointmentSlot < ApplicationRecord
  # Associations
  belongs_to :doctor, class_name: 'User', foreign_key: :doctor_id

  # Validations
  validates :start_time, :end_time, presence: true
  validates :frequency_minutes, presence: true, numericality: { greater_than: 0 }
  validate :end_time_after_start_time
  validate :doctor_must_be_doctor_role

  # Scopes
  scope :open, -> { where(is_open: true) }
  scope :upcoming, -> { where('start_time >= ?', Time.current) }

  # Instance methods
  def generate_available_times
    return [] unless is_open

    times = []
    current_time = start_time

    while current_time < end_time
      next_time = current_time + frequency_minutes.minutes

      # Check if this slot is already booked
      unless doctor.doctor_appointments.where(
        "scheduled_start < ? AND scheduled_end > ?",
        next_time,
        current_time
      ).exists?
        times << { start: current_time, end: next_time }
      end

      current_time = next_time
    end

    times
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def doctor_must_be_doctor_role
    errors.add(:doctor, "must have doctor role") unless doctor&.doctor?
  end
end
