class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @tab = params[:tab].presence_in(%w[bookmarks likes reviews]) || "bookmarks"
    if @tab == "likes"
      @liked_reviews = Review.includes(
        :product,
        user: { avatar_attachment: :blob }
      ).joins(:review_likes).where(review_likes: { user_id: @user.id }).distinct.page(params[:page]).per(3)
    elsif @tab == "reviews"
      @reviews = @user.reviews.includes(
        :product,
        user: { avatar_attachment: :blob }
      ).order(created_at: :desc).page(params[:page]).per(3)
    else
      @bookmarked_products = @user.bookmark_products.page(params[:page])
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

  def destroy
    user = current_user
    user.update!(deleted_at: Time.current)
    UserDeletionJob.set(wait: 30.days).perform_later(user.id)
    sign_out user
    redirect_to root_path, notice: "退会手続きを受け付けました。"
  end

  private

  def profile_params
    params.require(:user).permit(:username, :avatar)
  end
end
