

ActiveRecord::Schema[7.0].define(version: 2024_03_26_084509) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "teacher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "images", default: []
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.integer "course_id"
    t.string "certificate_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "qr_code"
    t.string "certificate_url"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
