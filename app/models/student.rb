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


    line1_x = (image.width - 200) / 2 - 15
    line1_y = (image.width - 200) / 2 + 35
    image.combine_options do |c|
      c.font Rails.root.join('public', 'arial.ttf')
      c.fill "black"
      c.pointsize 13  
      c.draw "text #{line1_x},#{line1_y} '\"DON STROY PROJECT\" MCHJning kadrlar malakasini oshirish bo\\'limida '"
    end

    # Calculate the starting position for the course name
    course_name_x = (image.width - 200) / 2
    course_name_y = (image.width - 200) / 2 + 55

    if course.name.length > 55
      # Split the course name into two lines
      first_line = course.name[0..49]
      second_line = course.name[50..-1]

      # Calculate the starting position for the first line
      first_line_length = first_line.length
      half_first_line_width = (first_line_length * 10) / 2  
      first_line_start_x = (center_x + 70) - half_first_line_width

      # Calculate the starting position for the second line
      second_line_length = second_line.length
      half_second_line_width = (second_line_length * 10) / 2  
      second_line_start_x = (center_x + 70) - half_second_line_width

      # Draw the first line
      image.combine_options do |c|
        c.fill "black"
        c.pointsize 14
        c.font Rails.root.join('public', 'arial.ttf')
        c.font Rails.root.join('public', 'arial_bold.ttf')
        c.draw "text #{first_line_start_x},#{course_name_y} '#{first_line.gsub("'", "\\\\'")}'"
      end

      # Draw the second line
      image.combine_options do |c|
        c.fill "black"
        c.pointsize 14
        c.font Rails.root.join('public', 'arial.ttf')
        c.font Rails.root.join('public', 'arial_bold.ttf')
        c.draw "text #{second_line_start_x},#{course_name_y + 20} '#{second_line.gsub("'", "\\\\'")}'"
      end
    else
      # If the course name's length is within 50 characters, draw it on a single line
      course_length = course.name.length
      half_course_width = (course_length * 10) / 2
      course_start_x = (center_x + 30) - half_course_width
      escaped_course = course.name.gsub("'", "\\\\'")
      image.combine_options do |c|
        c.fill "black"
        c.pointsize 14
        c.font Rails.root.join('public', 'arial.ttf')
        c.font Rails.root.join('public', 'arial_bold.ttf')
        c.draw "text #{course_start_x},#{course_name_y} '#{escaped_course}'"
      end
    end

    if course.name.length > 65
      next_line = 0
    else
      next_line = 20
    end

    line3_x = (image.width - 200) / 2 - 13
    line3_y = (image.width - 200) / 2 + 55 + next_line
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 13
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line3_x},#{line3_y} 'bo\\'yicha #{hour} soatlik soxaviy mavzularini o\\'qidi, yakuniy baholashni ijobiy'"
    end

    line4_x = (image.width - 200) / 2 
    line4_y = (image.width - 200) / 2 + 75 + next_line
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 13
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line4_x},#{line4_y} 'topshirganligi uchun \"#{control}\" bo\\'yicha sertifikat berildi'"
    end

    level_x = (image.width - 200) / 2 + 160
    level_y = (image.width - 200) / 2 + 135
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 16
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{level_x},#{level_y} '#{level}'"
    end

    line6_x = (image.width - 200) / 2 + 115
    line6_y = (image.width - 200) / 2 + 185
    image.combine_options do |c|
      c.fill "black"
      c.pointsize 13
      c.font Rails.root.join('public', 'arial.ttf')
      c.draw "text #{line6_x},#{line6_y} 'Amal qilish muddati'"
    end

    certificate_date_x = (image.width - 200) / 2 + 140
    certificate_date_y = image.height - 40
    expiration_date_x = (image.width - 200) / 2  + 140
    expiration_date_y = image.height - 20
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
