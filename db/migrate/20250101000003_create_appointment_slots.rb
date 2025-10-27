class CreateAppointmentSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :appointment_slots do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :frequency_minutes, default: 15
      t.boolean :is_open, default: true

      t.timestamps
    end

    add_index :appointment_slots, [:doctor_id, :start_time]
  end
end
