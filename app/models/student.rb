class Student < ApplicationRecord
  belongs_to :course
  before_create :generate_certificate_number

  private

  def generate_certificate_number
    self.certificate_number = SecureRandom.hex(4)
  end

end