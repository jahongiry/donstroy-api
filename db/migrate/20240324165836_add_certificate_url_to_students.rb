class AddCertificateUrlToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :certificate_url, :string
  end
end
