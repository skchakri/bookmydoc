class SymptomReport < ApplicationRecord
  # Associations
  belongs_to :patient, class_name: 'User', foreign_key: :patient_id

  # Validations
  validates :free_text_description, presence: true
  validates :patient, presence: true
  validate :patient_must_be_patient_role

  # Callbacks
  after_create :analyze_symptoms

  # Instance methods
  def analyze_symptoms
    result = AiTriageService.analyze(free_text_description)
    update(
      ai_predicted_condition: result[:condition],
      ai_recommended_specializations: result[:specializations]
    )
  end

  def recommended_doctors(patient_location: nil)
    return User.none if ai_recommended_specializations.blank?

    doctors = User.verified_doctors.where(specialization: ai_recommended_specializations)

    if patient_location && patient.latitude && patient.longitude
      doctors = doctors.nearby(patient.latitude, patient.longitude)
    end

    doctors.order('
      (6371 * acos(
        cos(radians(?)) * cos(radians(latitude)) *
        cos(radians(longitude) - radians(?)) +
        sin(radians(?)) * sin(radians(latitude))
      )) ASC',
      patient.latitude, patient.longitude, patient.latitude
    )
  end

  private

  def patient_must_be_patient_role
    errors.add(:patient, "must have patient role") unless patient&.patient?
  end
end
