class ReviewLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review

  def create
    current_user.like(@review)
    redirect_to review_path(@review), notice: "レビューにいいねしました。"
  end

  def destroy
    current_user.unlike(@review)
    redirect_to review_path(@review), notice: "レビューのいいねを解除しました。"
  end

  private

  def set_review
    @review = Review.find(params[:review_id])
  end
end
