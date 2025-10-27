class Appointment < ApplicationRecord
  # Enums
  enum status: {
    pending_payment: 0,
    confirmed: 1,
    completed: 2,
    cancelled: 3,
    moved_by_doctor: 4
  }

  enum payment_status: {
    unpaid: 0,
    partial_paid: 1,
    paid: 2
  }

  # Associations
  belongs_to :doctor, class_name: 'User', foreign_key: :doctor_id
  belongs_to :patient, class_name: 'User', foreign_key: :patient_id
  has_many :test_orders, dependent: :destroy
  has_one_attached :screenshot_attachment

  # Validations
  validates :scheduled_start, :scheduled_end, presence: true
  validate :scheduled_end_after_scheduled_start
  validate :doctor_must_be_doctor_role
  validate :patient_must_be_patient_role
  validate :no_overlapping_appointments, on: :create

  # Scopes
  scope :upcoming, -> { where('scheduled_start >= ?', Time.current).order(scheduled_start: :asc) }
  scope :past, -> { where('scheduled_start < ?', Time.current).order(scheduled_start: :desc) }
  scope :today, -> { where(scheduled_start: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :this_week, -> { where(scheduled_start: Time.current.beginning_of_week..Time.current.end_of_week) }

  # Callbacks
  after_update :notify_patient_if_rescheduled, if: :saved_change_to_scheduled_start?

  # Instance methods
  def reschedule!(new_start, new_end)
    self.moved_from = scheduled_start
    self.scheduled_start = new_start
    self.scheduled_end = new_end
    self.status = :moved_by_doctor

    save!

    # Notify patient
    Notification.create!(
      user: patient,
      title: "Appointment Rescheduled",
      body: "Your appointment with Dr. #{doctor.full_name} has been moved from #{moved_from.strftime('%b %d, %Y at %I:%M %p')} to #{scheduled_start.strftime('%b %d, %Y at %I:%M %p')}",
      metadata: { appointment_id: id, action: 'rescheduled' }
    )
  end

  def mark_completed!
    update!(status: :completed)
  end

  def confirm_payment!
    update!(payment_status: :partial_paid, status: :confirmed)

    # Notify doctor
    Notification.create!(
      user: doctor,
      title: "New Appointment Confirmed",
      body: "#{patient.full_name} has booked an appointment on #{scheduled_start.strftime('%b %d, %Y at %I:%M %p')}",
      metadata: { appointment_id: id, action: 'confirmed' }
    )
  end

  def duration_minutes
    ((scheduled_end - scheduled_start) / 60).to_i
  end

  private

  def scheduled_end_after_scheduled_start
    return if scheduled_end.blank? || scheduled_start.blank?

    if scheduled_end <= scheduled_start
      errors.add(:scheduled_end, "must be after scheduled start")
    end
  end

  def doctor_must_be_doctor_role
    errors.add(:doctor, "must have doctor role") unless doctor&.doctor?
  end

  def patient_must_be_patient_role
    errors.add(:patient, "must have patient role") unless patient&.patient?
  end

  def no_overlapping_appointments
    overlapping = doctor.doctor_appointments.where(
      "scheduled_start < ? AND scheduled_end > ? AND id != ?",
      scheduled_end, scheduled_start, id || 0
    )

    if overlapping.exists?
      errors.add(:base, "Doctor already has an appointment during this time")
    end
  end

  def notify_patient_if_rescheduled
    if moved_by_doctor? && moved_from.present?
      Notification.create!(
        user: patient,
        title: "Appointment Rescheduled",
        body: "Your appointment has been rescheduled by Dr. #{doctor.full_name}",
        metadata: { appointment_id: id, action: 'rescheduled' }
      )
    end
  end
end
