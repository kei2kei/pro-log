class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [ :new, :create ]

  def new
    @review = @product.reviews.build
  end

  def show
    @review = Review.includes(
      user: { avatar_attachment: :blob },
      product: { image_attachment: :blob }
    ).find(params[:id])
    @other_reviews = @review.user.reviews.where.not(id: @review.id).includes(product: { image_attachment: :blob }).limit(4)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
