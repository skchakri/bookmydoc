module Doctors
  class QrCodesController < ApplicationController
    before_action :require_login
    before_action :require_doctor
    before_action :set_doctor

    def show
      # Display the QR code page (for viewing and printing)
      @doctor = current_user
    end

    def download
      qr_code = QrCodeGeneratorService.generate_for_doctor(@doctor)

      send_data qr_code.to_blob,
                type: 'image/png',
                filename: "dr_#{@doctor.full_name.parameterize}_qr_code.png",
                disposition: 'attachment'
    end

    def generate_image
      qr_code = QrCodeGeneratorService.generate_for_doctor(@doctor)

      send_data qr_code.to_blob,
                type: 'image/png',
                filename: "qr_code.png",
                disposition: 'inline'
    end

    private

    def set_doctor
      @doctor = current_user
      unless @doctor.doctor?
        flash[:alert] = "Only doctors can access QR codes"
        redirect_to root_path
      end
    end

    def require_doctor
      unless current_user&.doctor?
        flash[:alert] = "Access denied"
        redirect_to root_path
      end
    end
  end
end
