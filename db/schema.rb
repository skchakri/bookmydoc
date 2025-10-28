# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_28_060217) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointment_slots", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "frequency_minutes", default: 15
    t.boolean "is_open", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "start_time"], name: "index_appointment_slots_on_doctor_id_and_start_time"
    t.index ["doctor_id"], name: "index_appointment_slots_on_doctor_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.bigint "patient_id", null: false
    t.datetime "scheduled_start", null: false
    t.datetime "scheduled_end", null: false
    t.integer "status", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.integer "initial_fee_amount", default: 0
    t.integer "remaining_fee_amount", default: 0
    t.text "doctor_notes"
    t.text "patient_notes"
    t.string "audio_recording_url"
    t.datetime "moved_from"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "scheduled_start"], name: "index_appointments_on_doctor_id_and_scheduled_start"
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["patient_id", "scheduled_start"], name: "index_appointments_on_patient_id_and_scheduled_start"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["payment_status"], name: "index_appointments_on_payment_status"
    t.index ["status"], name: "index_appointments_on_status"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.datetime "created_at", precision: nil, null: false
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
    t.index ["user_id", "action"], name: "index_audit_logs_on_user_id_and_action"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "awards", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.string "title", null: false
    t.string "issuing_organization"
    t.date "date_received"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_awards_on_doctor_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.text "content", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id", "read_at"], name: "index_messages_on_receiver_id_and_read_at"
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id", "receiver_id"], name: "index_messages_on_sender_id_and_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.datetime "read_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.bigint "patient_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "patient_id"], name: "index_reviews_on_doctor_id_and_patient_id", unique: true
    t.index ["doctor_id"], name: "index_reviews_on_doctor_id"
    t.index ["patient_id"], name: "index_reviews_on_patient_id"
    t.index ["rating"], name: "index_reviews_on_rating"
  end

  create_table "symptom_reports", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.text "free_text_description", null: false
    t.string "ai_predicted_condition"
    t.jsonb "ai_recommended_specializations", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ai_symptom_details"
    t.text "ai_basic_care_recommendations"
    t.string "ai_urgency_level"
    t.string "symptom_duration"
    t.text "medications_taken"
    t.text "previous_tests"
    t.string "referred_by"
    t.index ["created_at"], name: "index_symptom_reports_on_created_at"
    t.index ["patient_id"], name: "index_symptom_reports_on_patient_id"
  end

  create_table "test_orders", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "doctor_id", null: false
    t.bigint "patient_id", null: false
    t.text "description", null: false
    t.text "message_to_patient"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_test_orders_on_appointment_id"
    t.index ["created_at"], name: "index_test_orders_on_created_at"
    t.index ["doctor_id"], name: "index_test_orders_on_doctor_id"
    t.index ["patient_id"], name: "index_test_orders_on_patient_id"
  end

  create_table "test_result_uploads", force: :cascade do |t|
    t.bigint "test_order_id"
    t.bigint "uploaded_by_patient_id", null: false
    t.text "notes_from_patient"
    t.bigint "reviewed_by_doctor_id"
    t.text "doctor_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_test_result_uploads_on_created_at"
    t.index ["reviewed_by_doctor_id"], name: "index_test_result_uploads_on_reviewed_by_doctor_id"
    t.index ["test_order_id"], name: "index_test_result_uploads_on_test_order_id"
    t.index ["uploaded_by_patient_id"], name: "index_test_result_uploads_on_uploaded_by_patient_id"
  end

  create_table "unavailable_dates", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.date "date", null: false
    t.string "reason"
    t.boolean "is_recurring", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "date"], name: "index_unavailable_dates_on_doctor_id_and_date", unique: true
    t.index ["doctor_id"], name: "index_unavailable_dates_on_doctor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "phone_number", null: false
    t.string "aadhaar_number"
    t.string "email"
    t.string "password_digest", null: false
    t.string "location_city"
    t.string "location_pin_code"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "specialization"
    t.integer "consultation_fee_initial", default: 0
    t.integer "consultation_fee_due", default: 0
    t.string "clinic_address"
    t.text "about_bio"
    t.string "medical_registration_number"
    t.integer "role", default: 0, null: false
    t.boolean "is_verified", default: false
    t.string "phone_otp_code"
    t.datetime "phone_verified_at"
    t.datetime "aadhaar_verified_at"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "address"
    t.integer "years_of_experience"
    t.text "certificates"
    t.text "awards"
    t.text "bio"
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.integer "testimonials_count", default: 0
    t.string "slug"
    t.index ["email"], name: "index_users_on_email"
    t.index ["latitude", "longitude"], name: "index_users_on_latitude_and_longitude"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["specialization"], name: "index_users_on_specialization"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointment_slots", "users", column: "doctor_id"
  add_foreign_key "appointments", "users", column: "doctor_id"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "awards", "users", column: "doctor_id"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "reviews", "users", column: "doctor_id"
  add_foreign_key "reviews", "users", column: "patient_id"
  add_foreign_key "symptom_reports", "users", column: "patient_id"
  add_foreign_key "test_orders", "appointments"
  add_foreign_key "test_orders", "users", column: "doctor_id"
  add_foreign_key "test_orders", "users", column: "patient_id"
  add_foreign_key "test_result_uploads", "test_orders"
  add_foreign_key "test_result_uploads", "users", column: "reviewed_by_doctor_id"
  add_foreign_key "test_result_uploads", "users", column: "uploaded_by_patient_id"
  add_foreign_key "unavailable_dates", "users", column: "doctor_id"
end
