class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [:sender_id, :receiver_id]
    add_index :messages, [:receiver_id, :read_at]
  end
end
