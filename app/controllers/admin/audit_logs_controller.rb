class Admin::AuditLogsController < ApplicationController
  before_action :require_admin

  def index
    @audit_logs = AuditLog.includes(:user, :target)

    # Filter by user
    if params[:user_id].present?
      @audit_logs = @audit_logs.where(user_id: params[:user_id])
    end

    # Filter by action
    if params[:action_name].present?
      @audit_logs = @audit_logs.where(action: params[:action_name])
    end

    @audit_logs = @audit_logs.order(created_at: :desc)
                             .page(params[:page]).per(50)
  end
end
