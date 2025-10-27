require 'rqrcode'
require 'chunky_png'
require 'mini_magick'

class QrCodeGeneratorService
  # Generate QR code for a doctor with their photo embedded in the center
  def self.generate_for_doctor(doctor)
    new(doctor).generate
  end

  def initialize(doctor)
    @doctor = doctor
    @qr_size = 10 # Size multiplier for QR code
    @photo_size_ratio = 0.25 # Photo takes 25% of QR code size
  end

  def generate
    # Generate QR code with doctor's profile URL
    qr_code = RQRCode::QRCode.new(doctor_url, level: :h, size: 8)

    # Convert QR code to PNG
    qr_png = qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: @qr_size,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 500
    )

    # If doctor has a profile photo, embed it in the center
    if @doctor.profile_photo.attached?
      embed_photo_in_qr(qr_png)
    else
      qr_png
    end
  end

  private

  def doctor_url
    # Generate URL to doctor's public profile
    Rails.application.routes.url_helpers.doctor_url(
      @doctor,
      host: ENV['APP_HOST'] || 'localhost:7000',
      protocol: 'http'
    )
  end

  def embed_photo_in_qr(qr_png)
    # Create a temporary file for the QR code
    qr_tempfile = Tempfile.new(['qr', '.png'])
    qr_tempfile.binmode
    qr_tempfile.write(qr_png.to_blob)
    qr_tempfile.rewind

    # Process with MiniMagick
    qr_image = MiniMagick::Image.open(qr_tempfile.path)
    qr_width = qr_image.width
    qr_height = qr_image.height

    # Calculate photo size (25% of QR code)
    photo_size = (qr_width * @photo_size_ratio).to_i

    # Download and process profile photo
    photo_tempfile = Tempfile.new(['photo', '.png'])
    photo_tempfile.binmode
    @doctor.profile_photo.download { |chunk| photo_tempfile.write(chunk) }
    photo_tempfile.rewind

    photo = MiniMagick::Image.open(photo_tempfile.path)

    # Resize and make photo circular
    photo.combine_options do |c|
      c.resize "#{photo_size}x#{photo_size}^"
      c.gravity 'center'
      c.extent "#{photo_size}x#{photo_size}"
    end

    # Create circular mask
    mask = MiniMagick::Image.open(photo_tempfile.path)
    mask.format 'png'
    mask.combine_options do |c|
      c.alpha 'transparent'
      c.background 'none'
      c.fill 'white'
      c.draw "circle #{photo_size/2},#{photo_size/2} #{photo_size/2},0"
    end

    # Apply mask to make photo circular
    photo.composite(mask) do |c|
      c.alpha 'set'
      c.compose 'DstIn'
    end

    # Add white border to photo
    photo.combine_options do |c|
      c.bordercolor 'white'
      c.border '10'
    end

    # Composite photo onto QR code center
    qr_image.composite(photo) do |c|
      c.gravity 'center'
      c.compose 'over'
    end

    # Convert back to PNG blob
    result = ChunkyPNG::Image.from_blob(qr_image.to_blob)

    # Clean up temp files
    qr_tempfile.close
    qr_tempfile.unlink
    photo_tempfile.close
    photo_tempfile.unlink

    result
  rescue => e
    Rails.logger.error "Error embedding photo in QR code: #{e.message}"
    # Return QR code without photo if there's an error
    qr_png
  end
end
