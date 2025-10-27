class SymptomReportsController < ApplicationController
  before_action :require_patient, only: [:new, :create]
  before_action :require_login, only: [:show]

  def new
    @symptom_report = SymptomReport.new
  end

  def create
    @symptom_report = current_user.symptom_reports.build(symptom_report_params)

    if @symptom_report.save
      audit_log(action: 'create_symptom_report', target: @symptom_report)

      flash[:notice] = "Symptoms recorded successfully"
      redirect_to symptom_report_path(@symptom_report)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @symptom_report = SymptomReport.find(params[:id])

    # Security check
    unless current_admin? || @symptom_report.patient == current_user
      flash[:alert] = "Access denied"
      redirect_to root_path and return
    end

    @recommended_doctors = @symptom_report.recommended_doctors(patient_location: true)
                                          .includes(:avatar_attachment)
                                          .limit(10)

    @last_visited_doctor = current_user.last_visited_doctor if current_patient?

    audit_log(action: 'view_symptom_report', target: @symptom_report)
  end

  private

  def symptom_report_params
    params.require(:symptom_report).permit(:free_text_description)
  end
end
