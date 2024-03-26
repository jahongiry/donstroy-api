class AddImagesToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :images, :jsonb, default: []
  end
end
