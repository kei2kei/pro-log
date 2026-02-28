class ReviewLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @review = Review.find(params[:review_id])
    like = current_user.review_likes.find_or_initialize_by(review: @review)

    unless like.persisted?
      ReviewLike.transaction do
        like.save!
        create_like_notification!(like)
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to review_path(@review), notice: t("reviews.likes.notice.created") }
    end
  rescue ActiveRecord::ActiveRecordError
    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = t("reviews.likes.alert.create_failed")
        render turbo_stream: [
          turbo_stream.replace(
            view_context.dom_id(@review, :like),
            partial: "shared/like_buttons",
            locals: { review: @review }
          ),
          turbo_stream.replace("flash", partial: "shared/flash")
        ], status: :unprocessable_entity
      end
      format.html do
        redirect_back fallback_location: review_path(@review),
                      alert: t("reviews.likes.alert.create_failed")
      end
    end
  end

  def destroy
    like = current_user.review_likes.find(params[:id])
    @review = like.review
    if like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to review_path(@review), notice: t("reviews.likes.notice.destroyed") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = t("reviews.likes.alert.destroy_failed")
          render turbo_stream: [
            turbo_stream.replace(
              view_context.dom_id(@review, :like),
              partial: "shared/like_buttons",
              locals: { review: @review }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ], status: :unprocessable_entity
        end
        format.html do
          redirect_back fallback_location: review_path(@review),
                        alert: t("reviews.likes.alert.destroy_failed")
        end
      end
    end
  end

  private

  def create_like_notification!(like)
    return if @review.user_id == current_user.id

    Notification.create!(
      recipient: @review.user,
      actor: current_user,
      notifiable: like
    )
  end
end
