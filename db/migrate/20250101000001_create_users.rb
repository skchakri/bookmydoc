class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :phone_number, null: false
      t.string :aadhaar_number
      t.string :email
      t.string :password_digest, null: false
      t.string :location_city
      t.string :location_pin_code
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :specialization
      t.integer :consultation_fee_initial, default: 0
      t.integer :consultation_fee_due, default: 0
      t.string :clinic_address
      t.text :about_bio
      t.string :medical_registration_number
      t.integer :role, default: 0, null: false
      t.boolean :is_verified, default: false
      t.string :phone_otp_code
      t.datetime :phone_verified_at
      t.datetime :aadhaar_verified_at
      t.datetime :last_login_at

      t.timestamps
    end

    add_index :users, :phone_number, unique: true
    add_index :users, :email
    add_index :users, :role
    add_index :users, [:latitude, :longitude]
    add_index :users, :specialization
  end
end
