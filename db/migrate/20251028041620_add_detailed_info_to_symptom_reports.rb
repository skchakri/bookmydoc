class AddDetailedInfoToSymptomReports < ActiveRecord::Migration[7.1]
  def change
    add_column :symptom_reports, :symptom_duration, :string
    add_column :symptom_reports, :medications_taken, :text
    add_column :symptom_reports, :previous_tests, :text
    add_column :symptom_reports, :referred_by, :string
  end
end
