class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [ :new, :create ]
  before_action :set_review, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_review!, only: [ :edit, :update, :destroy ]

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to review_path(@review), notice: "レビューを投稿しました。", flash: { share_prompt: true }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @other_reviews = @review.user.reviews.where.not(id: @review.id).includes(product: { image_attachment: :blob }).limit(4)
  end

  def edit
    @product = @review.product
  end

  def update
    @product = @review.product

    if @review.update(review_params)
      redirect_to review_path(@review), notice: "レビューを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    product = @review.product
    @review.destroy
    redirect_to product_path(product), notice: "レビューを削除しました。"
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = Review.includes(
      user: { avatar_attachment: :blob },
      product: { image_attachment: :blob }
    ).find(params[:id])
  end

  def authorize_review!
    return if @review.user == current_user

    redirect_to review_path(@review), alert: "この操作は許可されていません。"
  end

  def review_params
    params.require(:review).permit(
      :title,
      :comment,
      :tag_names,
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
