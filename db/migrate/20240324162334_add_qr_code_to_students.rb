class AddQrCodeToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :qr_code, :string
  end
end
