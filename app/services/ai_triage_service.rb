class AiTriageService
  # This is a stub service for AI-based symptom triage
  # In production, integrate with medical AI APIs or LLMs with medical knowledge

  SYMPTOM_KEYWORDS = {
    'Cardiologist' => ['chest pain', 'heart', 'cardiac', 'palpitation', 'blood pressure', 'hypertension'],
    'Dermatologist' => ['skin', 'rash', 'acne', 'eczema', 'psoriasis', 'mole', 'itching'],
    'ENT' => ['ear', 'nose', 'throat', 'sinus', 'tonsil', 'hearing', 'vertigo', 'sore throat'],
    'General Physician' => ['fever', 'cold', 'cough', 'headache', 'body ache', 'fatigue', 'weakness'],
    'Gastroenterologist' => ['stomach', 'abdomen', 'digestive', 'nausea', 'vomit', 'diarrhea', 'constipation'],
    'Orthopedic' => ['bone', 'joint', 'fracture', 'sprain', 'back pain', 'knee pain', 'arthritis'],
    'Pediatrician' => ['child', 'baby', 'infant', 'toddler', 'vaccination'],
    'Psychiatrist' => ['anxiety', 'depression', 'stress', 'mental', 'sleep', 'insomnia', 'mood'],
    'Ophthalmologist' => ['eye', 'vision', 'sight', 'blind', 'cataract', 'glasses'],
    'Gynecologist' => ['pregnancy', 'menstrual', 'period', 'uterus', 'ovary', 'pcos'],
    'Neurologist' => ['brain', 'nerve', 'seizure', 'migraine', 'paralysis', 'tremor'],
    'Pulmonologist' => ['lung', 'breathing', 'asthma', 'bronchitis', 'tuberculosis', 'shortness of breath']
  }.freeze

  class << self
    def analyze(symptom_text)
      return default_response if symptom_text.blank?

      symptom_text = symptom_text.downcase

      # Match specializations based on keywords
      matched_specializations = []
      predicted_conditions = []

      SYMPTOM_KEYWORDS.each do |specialization, keywords|
        if keywords.any? { |keyword| symptom_text.include?(keyword) }
          matched_specializations << specialization

          # Generate a simple condition prediction
          matching_keywords = keywords.select { |k| symptom_text.include?(k) }
          predicted_conditions << "Possible #{matching_keywords.join(', ')} related condition"
        end
      end

      # Default to General Physician if no specific match
      if matched_specializations.empty?
        matched_specializations << 'General Physician'
        predicted_conditions << 'General medical consultation recommended'
      end

      {
        condition: predicted_conditions.first || 'Condition requires professional assessment',
        specializations: matched_specializations.uniq
      }
    end

    private

    def default_response
      {
        condition: 'Unable to assess. Please consult a healthcare professional.',
        specializations: ['General Physician']
      }
    end
  end
end
