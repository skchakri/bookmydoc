class NotificationsController < ApplicationController
  before_action :require_login

  def index
    @notifications = current_user.notifications.recent.page(params[:page]).per(20)
    audit_log(action: 'view_notifications')
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end

  def mark_all_read
    current_user.notifications.unread.each(&:mark_as_read!)

    flash[:notice] = "All notifications marked as read"
    redirect_to notifications_path
  end
end
