class AddExtraColumnsToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :hour, :string
    add_column :students, :level, :string
    add_column :students, :control, :string
    add_column :students, :passport, :string
  end
end
