class TestResultUpload < ApplicationRecord
  # Associations
  belongs_to :test_order, optional: true
  belongs_to :uploaded_by_patient, class_name: 'User', foreign_key: :uploaded_by_patient_id
  belongs_to :reviewed_by_doctor, class_name: 'User', foreign_key: :reviewed_by_doctor_id, optional: true
  has_one_attached :file

  # Validations
  validates :file, presence: true
  validates :uploaded_by_patient, presence: true
  validate :uploaded_by_patient_must_be_patient_role
  validate :reviewed_by_doctor_must_be_doctor_role, if: :reviewed_by_doctor_id?
  validates :file, content_type: ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'],
                   size: { less_than: 10.megabytes }

  # Callbacks
  after_create :notify_doctor

  # Scopes
  scope :reviewed, -> { where.not(reviewed_by_doctor_id: nil) }
  scope :pending_review, -> { where(reviewed_by_doctor_id: nil) }

  # Instance methods
  def reviewed?
    reviewed_by_doctor_id.present?
  end

  def review_by!(doctor, comments)
    update!(
      reviewed_by_doctor: doctor,
      doctor_comments: comments
    )
  end

  private

  def uploaded_by_patient_must_be_patient_role
    errors.add(:uploaded_by_patient, "must have patient role") unless uploaded_by_patient&.patient?
  end

  def reviewed_by_doctor_must_be_doctor_role
    errors.add(:reviewed_by_doctor, "must have doctor role") unless reviewed_by_doctor&.doctor?
  end

  def notify_doctor
    # Find doctors who have appointments with this patient
    doctor = if test_order.present?
      test_order.doctor
    else
      uploaded_by_patient.patient_appointments.order(scheduled_start: :desc).first&.doctor
    end

    return unless doctor

    Notification.create!(
      user: doctor,
      title: "New Test Result Uploaded",
      body: "#{uploaded_by_patient.full_name} has uploaded a new test result",
      metadata: { test_result_upload_id: id, patient_id: uploaded_by_patient_id, action: 'result_uploaded' }
    )
  end
end
