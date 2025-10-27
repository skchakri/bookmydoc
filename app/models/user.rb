class User < ApplicationRecord
  has_secure_password

  # Enums
  enum role: { patient: 0, doctor: 1, admin: 2 }

  # Active Storage attachments
  has_one_attached :avatar
  has_one_attached :profile_photo
  has_one_attached :medical_certificate

  # Associations
  has_many :symptom_reports, foreign_key: :patient_id, dependent: :destroy
  has_many :doctor_appointments, class_name: 'Appointment', foreign_key: :doctor_id
  has_many :patient_appointments, class_name: 'Appointment', foreign_key: :patient_id
  has_many :appointment_slots, foreign_key: :doctor_id, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :test_orders_as_doctor, class_name: 'TestOrder', foreign_key: :doctor_id
  has_many :test_orders_as_patient, class_name: 'TestOrder', foreign_key: :patient_id
  has_many :test_result_uploads, foreign_key: :uploaded_by_patient_id
  has_many :awards, foreign_key: :doctor_id, dependent: :destroy
  has_many :unavailable_dates, foreign_key: :doctor_id, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: :receiver_id, dependent: :destroy
  has_many :reviews_as_doctor, class_name: 'Review', foreign_key: :doctor_id, dependent: :destroy
  has_many :reviews_as_patient, class_name: 'Review', foreign_key: :patient_id, dependent: :destroy

  # Validations
  validates :full_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\+?[0-9]{10,15}\z/, message: "must be a valid phone number" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :role, presence: true
  validates :specialization, presence: true, if: :doctor?
  validates :consultation_fee_initial, numericality: { greater_than_or_equal_to: 0 }, if: :doctor?
  validates :consultation_fee_due, numericality: { greater_than_or_equal_to: 0 }, if: :doctor?

  # Scopes
  scope :verified_doctors, -> { where(role: :doctor, is_verified: true) }
  scope :by_specialization, ->(spec) { where(specialization: spec) }
  scope :nearby, ->(lat, lng, radius_km = 20) {
    where("
      (6371 * acos(
        cos(radians(?)) * cos(radians(latitude)) *
        cos(radians(longitude) - radians(?)) +
        sin(radians(?)) * sin(radians(latitude))
      )) <= ?",
      lat, lng, lat, radius_km
    )
  }

  # Instance methods
  def appointments
    if doctor?
      doctor_appointments
    else
      patient_appointments
    end
  end

  def verify!
    update!(is_verified: true)
  end

  def distance_to(other_user)
    return nil if latitude.nil? || longitude.nil? || other_user.latitude.nil? || other_user.longitude.nil?

    DistanceService.calculate(latitude, longitude, other_user.latitude, other_user.longitude)
  end

  def last_visited_doctor
    return nil unless patient?

    last_appointment = patient_appointments.completed.order(scheduled_start: :desc).first
    last_appointment&.doctor
  end

  def unread_notifications_count
    notifications.where(read_at: nil).count
  end

  def unread_messages_count
    received_messages.unread.count
  end

  def conversations
    # Get all users who have had message exchanges with this user
    sent_to_ids = sent_messages.distinct.pluck(:receiver_id)
    received_from_ids = received_messages.distinct.pluck(:sender_id)
    user_ids = (sent_to_ids + received_from_ids).uniq

    User.where(id: user_ids)
  end

  def last_message_with(other_user)
    Message.between(self, other_user).last
  end

  def unread_messages_from(other_user)
    received_messages.where(sender: other_user).unread
  end

  def average_rating
    return 0 if reviews_as_doctor.empty?
    reviews_as_doctor.average_rating
  end

  def total_reviews
    reviews_as_doctor.total_count
  end

  def has_reviewed?(doctor)
    reviews_as_patient.exists?(doctor: doctor)
  end
end
