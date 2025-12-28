class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @tab = params[:tab].presence_in(%w[bookmarks likes reviews]) || "bookmarks"
    if @tab == "likes"
      @liked_reviews = Review.includes(
        user: { avatar_attachment: :blob },
        product: { image_attachment: :blob }
      ).joins(:review_likes).where(review_likes: { user_id: @user.id }).distinct
    elsif @tab == "reviews"
      @reviews = @user.reviews.includes(
        user: { avatar_attachment: :blob },
        product: { image_attachment: :blob }
      ).order(created_at: :desc)
    else
      @bookmarked_products = @user.bookmark_products.includes(image_attachment: :blob)
      @bookmarks_by_product_id = @user.product_bookmarks.index_by(&:product_id)
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :avatar)
  end
end
