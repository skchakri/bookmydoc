class CreateTestOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :test_orders do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.text :description, null: false
      t.text :message_to_patient

      t.timestamps
    end

    add_index :test_orders, :created_at
  end
end
