class AiTriageService
  # AI-powered symptom triage using Ollama via ruby_llm
  # Analyzes patient symptoms and recommends appropriate medical specializations

  AVAILABLE_SPECIALIZATIONS = [
    'Cardiologist',
    'Dermatologist',
    'ENT',
    'General Physician',
    'Gastroenterologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Ophthalmologist',
    'Gynecologist',
    'Neurologist',
    'Pulmonologist'
  ].freeze

  # Keyword-based fallback mapping for when AI is unavailable
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
    def analyze(symptom_text, additional_context = {})
      return default_response if symptom_text.blank?

      begin
        # Try AI-powered analysis first
        ai_analysis(symptom_text, additional_context)
      rescue => e
        # Fallback to keyword-based analysis if AI fails
        Rails.logger.error "AI Triage failed: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        fallback_analysis(symptom_text)
      end
    end

    private

    def ai_analysis(symptom_text, additional_context = {})
      prompt = build_medical_prompt(symptom_text, additional_context)

      # Get model from environment
      model = ENV.fetch('OLLAMA_MODEL', 'medllama2')

      # Call Ollama via ruby_llm using the builder pattern
      chat = RubyLLM.chat(model: model, provider: :ollama)
                    .with_temperature(0.3)
                    .with_params(num_predict: 800)

      # Send the prompt and get response
      response = chat.ask(prompt)

      Rails.logger.info "AI Triage Response: #{response.inspect}"

      # Extract response text from the last message
      response_text = response.messages.last&.content || response.to_s

      # Parse the response
      parse_ai_response(response_text)
    rescue StandardError => e
      Rails.logger.error "AI Triage Error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      fallback_analysis(symptom_text)
    end

    def build_medical_prompt(symptom_text, additional_context = {})
      # Build context information
      context_info = []

      if additional_context[:symptom_duration].present?
        duration_label = additional_context[:symptom_duration].to_s.humanize.gsub('_', ' ')
        context_info << "Duration: #{duration_label}"
      end

      if additional_context[:medications_taken].present?
        context_info << "Medications already taken: #{additional_context[:medications_taken]}"
      end

      if additional_context[:previous_tests].present?
        context_info << "Previous medical tests: #{additional_context[:previous_tests]}"
      end

      if additional_context[:referred_by].present?
        context_info << "Referred by: #{additional_context[:referred_by]}"
      end

      context_section = context_info.any? ? "\n\nAdditional Context:\n#{context_info.join("\n")}" : ""

      <<~PROMPT
        You are a medical triage assistant helping to analyze patient symptoms and provide comprehensive medical guidance.

        Available medical specializations:
        #{AVAILABLE_SPECIALIZATIONS.join(', ')}

        Patient's symptoms:
        "#{symptom_text}"#{context_section}

        Please provide a comprehensive analysis with the following sections:

        1. CONDITION: Brief predicted condition or diagnosis (1-2 sentences, be specific but cautious)

        2. SYMPTOM DETAILS: Detailed explanation of the symptoms (3-4 sentences):
           - What these symptoms typically indicate
           - Possible causes or triggers
           - What to watch out for
           - When symptoms might worsen

        3. BASIC CARE: Home care and over-the-counter recommendations (3-4 bullet points):
           - Self-care measures (rest, hydration, diet)
           - Over-the-counter medications that may help (be specific with names)
           - Things to avoid
           - Warning signs that require immediate medical attention

        4. SPECIALIZATIONS: Recommended medical specialist(s) from the available list (1-3 specialists, comma-separated)

        5. URGENCY: Level of urgency (choose one: EMERGENCY, URGENT, MODERATE, ROUTINE)

        Format your response EXACTLY as follows:
        CONDITION: [Your predicted condition here]

        SYMPTOM DETAILS: [Detailed explanation of symptoms, causes, and progression]

        BASIC CARE:
        - [Self-care recommendation 1]
        - [Medication recommendation 2]
        - [Things to avoid 3]
        - [Warning signs 4]

        SPECIALIZATIONS: [Comma-separated list of specializations from the available list only]

        URGENCY: [EMERGENCY/URGENT/MODERATE/ROUTINE]

        Important guidelines:
        - Be conservative and prioritize patient safety
        - Only recommend OTC medications that are widely available and safe
        - For OTC meds, suggest generic names (e.g., "ibuprofen" not brand names)
        - If symptoms are severe, mark as EMERGENCY or URGENT
        - Only use specializations from the provided list
        - If symptoms are unclear, recommend General Physician with ROUTINE urgency

        Example response:
        CONDITION: Possible upper respiratory tract infection with persistent cough and fever, likely viral in nature

        SYMPTOM DETAILS: The combination of fever, cough, and body aches suggests a viral respiratory infection, commonly known as the flu or common cold. These infections typically spread through respiratory droplets and are more common during seasonal changes. The fever indicates your body is fighting the infection. Symptoms usually peak within 2-3 days and gradually improve over 7-10 days.

        BASIC CARE:
        - Get plenty of rest and stay hydrated with water, warm fluids, and herbal teas
        - Take acetaminophen (Tylenol) or ibuprofen (Advil) for fever and body aches as directed on package
        - Avoid cold drinks, smoking, and polluted environments that can irritate airways
        - Seek immediate care if fever exceeds 103°F (39.4°C), difficulty breathing, chest pain, or symptoms worsen after 5 days

        SPECIALIZATIONS: General Physician, Pulmonologist

        URGENCY: MODERATE
      PROMPT
    end

    def parse_ai_response(response_text)
      # Extract all sections from formatted response
      condition_match = response_text.match(/CONDITION:\s*(.+?)(?=\n\nSYMPTOM DETAILS:|SYMPTOM DETAILS:|SPECIALIZATIONS:|$)/m)
      symptom_details_match = response_text.match(/SYMPTOM DETAILS:\s*(.+?)(?=\n\nBASIC CARE:|BASIC CARE:|SPECIALIZATIONS:|$)/m)
      basic_care_match = response_text.match(/BASIC CARE:\s*(.+?)(?=\n\nSPECIALIZATIONS:|SPECIALIZATIONS:|URGENCY:|$)/m)
      specializations_match = response_text.match(/SPECIALIZATIONS:\s*(.+?)(?=\n\nURGENCY:|URGENCY:|$)/m)
      urgency_match = response_text.match(/URGENCY:\s*(.+?)$/m)

      # Parse condition
      condition = condition_match ? condition_match[1].strip : "Requires professional medical assessment"

      # Parse symptom details
      symptom_details = symptom_details_match ? symptom_details_match[1].strip : nil

      # Parse basic care recommendations
      basic_care_text = basic_care_match ? basic_care_match[1].strip : nil
      basic_care_recommendations = if basic_care_text
        basic_care_text.split("\n").map { |line| line.strip.sub(/^-\s*/, '') }.reject(&:empty?)
      else
        []
      end

      # Parse specializations
      specializations_text = specializations_match ? specializations_match[1].strip : "General Physician"
      specializations = specializations_text
        .split(',')
        .map(&:strip)
        .select { |spec| AVAILABLE_SPECIALIZATIONS.include?(spec) }

      # Default to General Physician if no valid specializations
      specializations = ['General Physician'] if specializations.empty?

      # Parse urgency
      urgency_text = urgency_match ? urgency_match[1].strip.upcase : "ROUTINE"
      urgency = %w[EMERGENCY URGENT MODERATE ROUTINE].include?(urgency_text) ? urgency_text : "ROUTINE"

      {
        condition: condition,
        symptom_details: symptom_details,
        basic_care_recommendations: basic_care_recommendations,
        specializations: specializations.uniq,
        urgency: urgency
      }
    end

    def fallback_analysis(symptom_text)
      # Keyword-based fallback when AI is unavailable
      symptom_text = symptom_text.downcase
      matched_specializations = []
      predicted_conditions = []

      SYMPTOM_KEYWORDS.each do |specialization, keywords|
        if keywords.any? { |keyword| symptom_text.include?(keyword) }
          matched_specializations << specialization
          matching_keywords = keywords.select { |k| symptom_text.include?(k) }
          predicted_conditions << "Possible #{matching_keywords.join(', ')} related condition"
        end
      end

      # Default to General Physician if no match
      if matched_specializations.empty?
        matched_specializations << 'General Physician'
        predicted_conditions << 'General medical consultation recommended (AI analysis unavailable)'
      end

      {
        condition: predicted_conditions.first || 'Condition requires professional assessment',
        symptom_details: 'AI analysis temporarily unavailable. Please consult with a healthcare professional for detailed symptom assessment.',
        basic_care_recommendations: [
          'Consult with a healthcare professional for proper diagnosis',
          'Monitor your symptoms and note any changes',
          'Seek immediate medical attention if symptoms worsen',
          'Keep a record of when symptoms started and their severity'
        ],
        specializations: matched_specializations.uniq,
        urgency: 'MODERATE'
      }
    end

    def default_response
      {
        condition: 'Unable to assess. Please consult a healthcare professional.',
        symptom_details: nil,
        basic_care_recommendations: [],
        specializations: ['General Physician'],
        urgency: 'ROUTINE'
      }
    end
  end
end
