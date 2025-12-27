class ReviewsController < ApplicationController
  def show
    @review = Review.includes(
      user: { avatar_attachment: :blob },
      product: { image_attachment: :blob }
    ).find(params[:id])
    @other_reviews = @review.user.reviews.where.not(id: @review.id).includes(product: { image_attachment: :blob }).limit(4)
  end
end
