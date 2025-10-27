class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.datetime :scheduled_start, null: false
      t.datetime :scheduled_end, null: false
      t.integer :status, default: 0, null: false
      t.integer :payment_status, default: 0, null: false
      t.integer :initial_fee_amount, default: 0
      t.integer :remaining_fee_amount, default: 0
      t.text :doctor_notes
      t.text :patient_notes
      t.string :audio_recording_url
      t.datetime :moved_from

      t.timestamps
    end

    add_index :appointments, [:doctor_id, :scheduled_start]
    add_index :appointments, [:patient_id, :scheduled_start]
    add_index :appointments, :status
    add_index :appointments, :payment_status
  end
end
