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
    # Build additional context for AI analysis
    additional_context = {
      symptom_duration: symptom_duration,
      medications_taken: medications_taken,
      previous_tests: previous_tests,
      referred_by: referred_by
    }.compact

    result = AiTriageService.analyze(free_text_description, additional_context)
    update(
      ai_predicted_condition: result[:condition],
      ai_symptom_details: result[:symptom_details],
      ai_basic_care_recommendations: result[:basic_care_recommendations]&.to_json,
      ai_recommended_specializations: result[:specializations],
      ai_urgency_level: result[:urgency]
    )
  end

  # Helper method to parse basic care recommendations from JSON
  def parsed_basic_care_recommendations
    return [] if ai_basic_care_recommendations.blank?

    begin
      JSON.parse(ai_basic_care_recommendations)
    rescue JSON::ParserError
      []
    end
  end

  def recommended_doctors(patient_location: nil)
    return User.none if ai_recommended_specializations.blank?

    doctors = User.verified_doctors.where(specialization: ai_recommended_specializations)

    # Only apply location-based filtering and ordering if patient has coordinates
    if patient_location && patient.latitude.present? && patient.longitude.present?
      doctors = doctors.nearby(patient.latitude, patient.longitude)

      # Order by distance from patient
      doctors = doctors.order(
        Arel.sql("(6371 * acos(
          cos(radians(#{patient.latitude.to_f})) * cos(radians(latitude)) *
          cos(radians(longitude) - radians(#{patient.longitude.to_f})) +
          sin(radians(#{patient.latitude.to_f})) * sin(radians(latitude))
        )) ASC")
      )
    else
      # If no patient location, just order by name
      doctors = doctors.order(:full_name)
    end

    doctors
  end

  private

  def patient_must_be_patient_role
    errors.add(:patient, "must have patient role") unless patient&.patient?
  end
end
