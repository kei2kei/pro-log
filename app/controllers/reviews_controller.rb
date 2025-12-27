class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [ :new, :create ]

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to review_path(@review), notice: "レビューを投稿しました。"
    else
      render :new, status: :unprocessable_entity
    end
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

  def review_params
    params.require(:review).permit(
      :title,
      :comment,
      :overall_score,
      :sweetness,
      :richness,
      :aftertaste,
      :flavor_score,
      :solubility,
      :foam
    )
  end
end
