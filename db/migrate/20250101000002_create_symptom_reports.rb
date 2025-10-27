class CreateSymptomReports < ActiveRecord::Migration[7.1]
  def change
    create_table :symptom_reports do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.text :free_text_description, null: false
      t.string :ai_predicted_condition
      t.jsonb :ai_recommended_specializations, default: []

      t.timestamps
    end

    add_index :symptom_reports, :created_at
  end
end
