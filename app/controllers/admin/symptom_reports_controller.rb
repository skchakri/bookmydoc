class Admin::SymptomReportsController < ApplicationController
  before_action :require_admin

  def index
    @symptom_reports = SymptomReport.includes(:patient)
                                    .order(created_at: :desc)
                                    .page(params[:page]).per(20)

    audit_log(action: 'view_symptom_reports_admin')
  end

  def show
    @symptom_report = SymptomReport.find(params[:id])
    audit_log(action: 'view_symptom_report_admin', target: @symptom_report)
  end
end
