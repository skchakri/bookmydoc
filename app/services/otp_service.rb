class OtpService
  # This is a stub service for OTP functionality
  # In production, integrate with SMS gateway like Twilio, AWS SNS, or Indian providers like MSG91

  class << self
    def send_code(phone_number)
      # Generate 6-digit OTP
      code = generate_code

      # TODO: Integrate with SMS provider
      # Example: Twilio, MSG91, AWS SNS, etc.
      Rails.logger.info "OTP Code for #{phone_number}: #{code}"

      # For development, just return the code
      { success: true, code: code }
    end

    def verify_code(phone_number, code, stored_code)
      # In production, add expiration check (e.g., 10 minutes)
      code.to_s == stored_code.to_s
    end

    def generate_code
      # Generate 6-digit code
      rand(100000..999999).to_s
    end
  end
end
