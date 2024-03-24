# app/models/student.rb
class Student < ApplicationRecord
  belongs_to :course

  after_create :generate_certificate_with_url

  private

  def generate_certificate_with_url
    @uuid = SecureRandom.uuid
    url = "http://localhost:5173/student/#{id}"
    qr_code_path = generate_qr_code(@uuid, url)
    template_path = Rails.root.join('public', 'certificate.png')
    output_path = Rails.root.join('public', 'certificates', "#{@uuid}_certificate.png") 

    # Use MiniMagick to open the certificate template
    image = MiniMagick::Image.open(template_path)

    # Overlay the QR code onto the certificate
    qr_code_image = MiniMagick::Image.open(qr_code_path)
    x_offset = (image.width - qr_code_image.width) / 2
    y_offset = (image.height - qr_code_image.height) / 2

    x_offset += 400
    y_offset += 500

    image = image.composite(qr_code_image) do |c|
      c.compose "Over"
      c.geometry "+#{x_offset}+#{y_offset}"
    end

    # Add text to the certificate
    name_x = (image.width - 200) / 2 
    name_y = (image.height / 2) - 30  
    course_x = (image.width - 200) / 2
    course_y = (image.height / 2) + 30

    image.combine_options do |c|
      c.font "Arial"
      c.fill "black"
      c.draw "text #{name_x},#{name_y} 'Student Name: #{name}'"
      c.draw "text #{course_x},#{course_y} 'Course: #{course.name}'"
    end

    # Write the certificate image to the output path
    image.write(output_path)

    self.qr_code = "/qr_codes/#{@uuid}_qr_code.png"
    self.certificate_url = "/certificates/#{@uuid}_certificate.png"
    save  # Save the record with QR code and certificate URL
  end

  def generate_qr_code(uuid, url)
    qr = RQRCode::QRCode.new(url)
    png = qr.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 250,
      border_modules: 4,
      module_px_size: 6,
      file: nil 
    )
  
    qr_code_path = Rails.root.join('public', 'qr_codes', "#{uuid}_qr_code.png")

    File.open(qr_code_path, 'wb') { |file| file.write(png.to_s) }
    qr_code_path
  end
end
