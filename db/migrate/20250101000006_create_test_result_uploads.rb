class CreateTestResultUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :test_result_uploads do |t|
      t.references :test_order, foreign_key: true
      t.references :uploaded_by_patient, null: false, foreign_key: { to_table: :users }
      t.text :notes_from_patient
      t.references :reviewed_by_doctor, foreign_key: { to_table: :users }
      t.text :doctor_comments

      t.timestamps
    end

    add_index :test_result_uploads, :created_at
  end
end
