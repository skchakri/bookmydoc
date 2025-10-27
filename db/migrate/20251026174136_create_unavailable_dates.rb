class CreateUnavailableDates < ActiveRecord::Migration[7.1]
  def change
    create_table :unavailable_dates do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.date :date, null: false
      t.string :reason
      t.boolean :is_recurring, default: false

      t.timestamps
    end

    add_index :unavailable_dates, [:doctor_id, :date], unique: true
  end
end
