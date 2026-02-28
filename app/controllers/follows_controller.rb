class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find(params[:followed_id])

    if @user.id == current_user.id
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = t("shared.follow.cannot_follow_self")
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash"), status: :unprocessable_entity
        end
        format.html { redirect_back fallback_location: root_path, alert: t("shared.follow.cannot_follow_self") }
      end
      return
    end

    follow = current_user.active_follows.find_or_create_by(followed: @user)
    create_follow_notification!(follow) if follow.previously_new_record?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: t("shared.follow.followed") }
    end
  end

  def destroy
    follow = current_user.active_follows.find(params[:id])
    @user = follow.followed
    follow.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: t("shared.follow.unfollowed") }
    end
  end

  private

  def create_follow_notification!(follow)
    Notification.create!(
      recipient: @user,
      actor: current_user,
      notifiable: follow
    )
  end
end
