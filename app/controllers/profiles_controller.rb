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
      @reviewed_products = Product.joins(:reviews)
                                  .where(reviews: { user_id: @user.id })
                                  .distinct
                                  .includes(image_attachment: :blob)
    else
      @bookmarked_products = @user.bookmark_products.includes(image_attachment: :blob)
    end
  end

  def edit
    @user = current_user
  end

  def update
  end
end
