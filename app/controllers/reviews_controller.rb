class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_product, only: [ :new, :create ]
  before_action :set_review, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_review!, only: [ :edit, :update, :destroy ]

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.invalid?
      render :new, status: :unprocessable_entity
      return
    end

    Review.transaction do
      @review.save!
      create_review_notifications!
    end

    redirect_to review_path(@review), notice: "レビューを投稿しました。", flash: { share_prompt: true }
  rescue ActiveRecord::ActiveRecordError
    @review.errors.add(:base, "レビューの投稿に失敗しました。")
    render :new, status: :unprocessable_entity
  end

  def show
    @review_comments = @review.review_comments.includes(user: { avatar_attachment: :blob }).order(created_at: :desc)
    @review_comment = ReviewComment.new
    @other_reviews = @review.user.reviews.where.not(id: @review.id).includes(
      :product,
      :review_likes,
      user: { avatar_attachment: :blob }
    ).limit(4)
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
    if @review.destroy
      redirect_to product_path(product), notice: "レビューを削除しました。"
    else
      redirect_back fallback_location: review_path(@review),
                    alert: "レビューの削除に失敗しました。"
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = Review.includes(
      :review_likes,
      review_comments: { user: { avatar_attachment: :blob } },
      user: { avatar_attachment: :blob }
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

  def create_review_notifications!
    recipient_ids = current_user.passive_follows.distinct.pluck(:follower_id)
    return if recipient_ids.empty?

    now = Time.current
    Notification.insert_all!(
      recipient_ids.map do |recipient_id|
        {
          recipient_id: recipient_id,
          actor_id: current_user.id,
          notifiable_type: "Review",
          notifiable_id: @review.id,
          created_at: now,
          updated_at: now
        }
      end
    )
  end
end
