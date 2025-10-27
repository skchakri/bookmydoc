class TestOrder < ApplicationRecord
  # Associations
  belongs_to :appointment
  belongs_to :doctor, class_name: 'User', foreign_key: :doctor_id
  belongs_to :patient, class_name: 'User', foreign_key: :patient_id
  has_many :test_result_uploads, dependent: :destroy

  # Validations
  validates :description, presence: true
  validate :doctor_must_be_doctor_role
  validate :patient_must_be_patient_role

  # Callbacks
  after_create :notify_patient

  # Instance methods
  def has_results?
    test_result_uploads.any?
  end

  private

  def doctor_must_be_doctor_role
    errors.add(:doctor, "must have doctor role") unless doctor&.doctor?
  end

  def patient_must_be_patient_role
    errors.add(:patient, "must have patient role") unless patient&.patient?
  end

  def notify_patient
    Notification.create!(
      user: patient,
      title: "New Test Order from Dr. #{doctor.full_name}",
      body: "Dr. #{doctor.full_name} has requested: #{description}",
      metadata: { test_order_id: id, action: 'test_order_created' }
    )
  end
end
