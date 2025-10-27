class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :target_type
      t.bigint :target_id

      t.timestamp :created_at, null: false
    end

    add_index :audit_logs, [:target_type, :target_id]
    add_index :audit_logs, :created_at
    add_index :audit_logs, [:user_id, :action]
  end
end
