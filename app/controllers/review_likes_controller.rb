class ReviewLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @review = Review.find(params[:review_id])
    current_user.like(@review)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to review_path(@review), notice: "レビューにいいねしました。" }
    end
  end

  def destroy
    like = current_user.review_likes.find(params[:id])
    @review = like.review
    like.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to review_path(@review), notice: "レビューのいいねを解除しました。" }
    end
  end
end
