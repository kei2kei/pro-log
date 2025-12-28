class ReviewLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    review = Review.find(params[:review_id])
    current_user.like(review)
    redirect_to review_path(review), notice: "レビューにいいねしました。"
  end

  def destroy
    review = current_user.review_likes.find(params[:id]).review
    current_user.unlike(review)
    redirect_to review_path(review), notice: "レビューのいいねを解除しました。"
  end
end
