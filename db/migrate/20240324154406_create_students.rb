class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :name
      t.integer :course_id
      t.string :certificate_number

      t.timestamps
    end
  end
end
