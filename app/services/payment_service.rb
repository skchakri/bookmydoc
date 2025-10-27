class PaymentService
  # This is a stub service for payment integration
  # In production, integrate with Razorpay, PhonePe, Paytm, or other Indian payment gateways

  class << self
    def initiate_partial_payment(appointment, method: :upi)
      # Validate appointment
      return { success: false, error: 'Invalid appointment' } unless appointment.present?

      amount = appointment.initial_fee_amount

      # TODO: Integrate with payment gateway
      # Example: Razorpay, PhonePe, Paytm
      Rails.logger.info "Initiating payment: #{amount} INR via #{method} for appointment ##{appointment.id}"

      # Stub response - always succeeds in development
      {
        success: true,
        transaction_id: generate_transaction_id,
        amount: amount,
        method: method,
        status: 'completed'
      }
    end

    def verify_payment(transaction_id)
      # TODO: Verify payment with gateway
      Rails.logger.info "Verifying payment: #{transaction_id}"

      # Stub response
      {
        success: true,
        transaction_id: transaction_id,
        verified: true
      }
    end

    def process_razorpay_payment(appointment)
      # Razorpay specific integration stub
      initiate_partial_payment(appointment, method: :razorpay)
    end

    def process_phonepe_payment(appointment)
      # PhonePe specific integration stub
      initiate_partial_payment(appointment, method: :phonepe)
    end

    def process_paytm_payment(appointment)
      # Paytm specific integration stub
      initiate_partial_payment(appointment, method: :paytm)
    end

    private

    def generate_transaction_id
      "TXN#{Time.now.to_i}#{rand(1000..9999)}"
    end
  end
end
