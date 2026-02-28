class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.received_notifications.includes(:actor, :notifiable).recent.limit(100)
  end

  def read
    notification = current_user.received_notifications.find(params[:id])
    notification.update!(read_at: Time.current)

    redirect_to notifications_path
  end

  def read_all
    current_user.received_notifications.unread.update_all(read_at: Time.current)

    redirect_to notifications_path
  end
end
