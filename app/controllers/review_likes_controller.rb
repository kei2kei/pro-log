class ReviewLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @review = Review.find(params[:review_id])
    like = current_user.review_likes.find_or_initialize_by(review: @review)

    if like.persisted? || like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to review_path(@review), notice: "レビューにいいねしました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "レビューにいいねできませんでした。"
          render turbo_stream: [
            turbo_stream.replace(
              view_context.dom_id(@review, :like_buttons),
              partial: "shared/like_buttons",
              locals: { review: @review }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ], status: :unprocessable_entity
        end
        format.html do
          redirect_back fallback_location: review_path(@review),
                        alert: "レビューにいいねできませんでした。"
        end
      end
    end
  end

  def destroy
    like = current_user.review_likes.find(params[:id])
    @review = like.review
    if like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to review_path(@review), notice: "レビューのいいねを解除しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "レビューのいいね解除に失敗しました。"
          render turbo_stream: [
            turbo_stream.replace(
              view_context.dom_id(@review, :like_buttons),
              partial: "shared/like_buttons",
              locals: { review: @review }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ], status: :unprocessable_entity
        end
        format.html do
          redirect_back fallback_location: review_path(@review),
                        alert: "レビューのいいね解除に失敗しました。"
        end
      end
    end
  end
end
