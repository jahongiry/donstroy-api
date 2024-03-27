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
    extra_x_offset = 900
    extra_y_offset = 900

    image = image.composite(qr_code_image) do |c|
      c.compose "Over"
      x_offset = image.width - qr_code_image.width 
      y_offset = image.height - qr_code_image.height
      c.geometry "+#{x_offset}+#{y_offset}"
    end

    uzbekistan_x = (image.width - 200) / 2 + 90
    uzbekistan_y = 105 

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 16  
      c.draw "text #{uzbekistan_x},#{uzbekistan_y} 'O\\'ZBEKISTON RESPUBLIKASI'"
      c.weight "Bold"
    end

    talim_x = (image.width - 200) / 2 + 55
    talim_y = 130 

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 16  
      c.draw "text #{talim_x},#{talim_y} 'OLIY TA\\'LIM, FAN VA INNOVATSIYALAR'"
      c.weight "Bold"
    end

    vazirligi_x = (image.width - 200) / 2 + 170
    vazirligi_y = 155 

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 16  
      c.draw "text #{vazirligi_x},#{vazirligi_y} 'VAZIRLIGI'"
      c.weight "Bold"
    end

    uuid_x = (image.width - 200) / 2
    uuid_y = (image.height - 50) / 2

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 16  
      c.draw "text #{uuid_x},#{uuid_y} 'UUID: #{@uuid}'"
      c.weight "Bold"
    end

    # Add text to the certificate
    name_x = (image.width - 200) / 2 
    name_y = (image.height / 2) - 30  
    course_x = (image.width - 200) / 2
    course_y = (image.height / 2) + 30

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.draw "text #{name_x},#{name_y} 'Student Name: #{name}'"
      c.draw "text #{course_x},#{course_y} 'Course: #{course.name}'"
    end

    image.write(output_path)

    self.qr_code = "/qr_codes/#{@uuid}_qr_code.png"
    self.certificate_url = "/certificates/#{@uuid}_certificate.png"
    save  
  end

  def generate_qr_code(uuid, url)
    qr = RQRCode::QRCode.new(url)
    png = qr.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 120,
      border_modules: 4,
      module_px_size: 6,
      file: nil 
    )
  
    qr_code_path = Rails.root.join('public', 'qr_codes', "#{uuid}_qr_code.png")

    File.open(qr_code_path, 'wb') { |file| file.write(png.to_s) }
    qr_code_path
  end
end
