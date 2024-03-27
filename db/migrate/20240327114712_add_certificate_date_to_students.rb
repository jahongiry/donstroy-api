class AddCertificateDateToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :certificate_date, :datetime
  end
end
