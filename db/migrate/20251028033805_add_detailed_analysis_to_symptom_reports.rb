class AddDetailedAnalysisToSymptomReports < ActiveRecord::Migration[7.1]
  def change
    add_column :symptom_reports, :ai_symptom_details, :text
    add_column :symptom_reports, :ai_basic_care_recommendations, :text
    add_column :symptom_reports, :ai_urgency_level, :string
  end
end
