# app/models/student.rb
class Student < ApplicationRecord
  belongs_to :course

  after_create :generate_certificate_with_url

  private

  def generate_certificate_with_url
    @uuid = SecureRandom.uuid
    url = "https://donstroyproject.uz/student/#{id}"
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

    # Add text to the certificate
    name_x = (image.width - 200) / 2 + 100
    name_y = (image.height / 2) + 15   
    course_x = (image.width - 200) / 2
    course_y = (image.height / 2) + 30
    uzbekistan_x = (image.width - 200) / 2 + 80
    uzbekistan_y = 105 
    talim_x = (image.width - 200) / 2 + 45
    talim_y = 130 
    vazirligi_x = (image.width - 200) / 2 + 160
    vazirligi_y = 155
    uuid_x = (image.width - 200) / 2 + 180
    uuid_y = (image.height - 50) / 2 + 15

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 18  
      c.draw "text #{uzbekistan_x},#{uzbekistan_y} 'O\\'ZBEKISTON RESPUBLIKASI'"
      c.draw "text #{talim_x},#{talim_y} 'OLIY TA\\'LIM, FAN VA INNOVATSIYALAR'"
      c.draw "text #{vazirligi_x},#{vazirligi_y} 'VAZIRLIGI'"
    end

    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 14  
      c.draw "text #{uuid_x},#{uuid_y} '№: #{@uuid[0, 5]}'"
    end

    center_x = (image.width - 200) / 2 + 200
    name_length = name.length
    half_name_width = (name_length * 10) / 2  
    name_start_x = center_x - half_name_width
    escaped_name = name.gsub("'", "\\\\'")
    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial_bold.ttf')
      c.fill "black"
      c.pointsize 16  
      c.draw "text #{name_start_x },#{name_y} '#{escaped_name.upcase}'"
    end

    line1_x = (image.width - 200) / 2 - 10
    line1_y = (image.width - 200) / 2 + 35
    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 14  
      c.draw "text #{line1_x},#{line1_y} '\"DON STROY PROJECT\" MCHJ ning Kadrlar malakasini oshirish '"
    end

    line2_x = (image.width - 200) / 2 - 20
    line2_y = (image.width - 200) / 2 + 55
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 14

      # Draw the non-bold part of the text
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line2_x},#{line2_y} 'va sertifikatlash bo\\'limida '"

      # Draw the bold part of the text (course name)
      c.font Rails.root.join('public', 'arial_bold.ttf')
      c.draw "text #{line2_x + 180},#{line2_y} '#{course.name}'"
    end

    line3_x = (image.width - 200) / 2 + 5
    line3_y = (image.width - 200) / 2 + 75
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 14
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line3_x},#{line3_y} 'bo\\'yicha 72 soatlik soxaviy mavzularini o\\'qidi, yakuniy'"
    end

    line4_x = (image.width - 200) / 2 - 5
    line4_y = (image.width - 200) / 2 + 95
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 14
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line4_x},#{line4_y} 'baholashni ijobiy topshirganligi uchun \"Mualliflik nazorati\"'"
    end

    line5_x = (image.width - 200) / 2 + 100
    line5_y = (image.width - 200) / 2 + 115
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 14
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line5_x},#{line5_y} 'bo\\'yicha sertifikat berildi'"
    end

    line6_x = (image.width - 200) / 2 + 115
    line6_y = (image.width - 200) / 2 + 170
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 13
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line6_x},#{line6_y} 'Amal qilish muddati'"
    end

    certificate_date_x = (image.width - 200) / 2 + 140
    certificate_date_y = image.height - 50
    expiration_date_x = (image.width - 200) / 2  + 140
    expiration_date_y = image.height - 30
    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 14  
      c.draw "text #{certificate_date_x},#{certificate_date_y} '#{certificate_date.strftime("%d/%m/%Y")}'"
      c.draw "text #{expiration_date_x},#{expiration_date_y} '#{(certificate_date + 3.years).strftime("%d/%m/%Y")}'"
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
