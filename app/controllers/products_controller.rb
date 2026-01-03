class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Product.left_joins(:reviews).group(:id).ransack(params[:q])
    @products = @q.result.order(created_at: :desc).page(params[:page])
    @bookmarks_by_product_id = current_user.product_bookmarks.index_by(&:product_id)
  end

  def show
    @product = Product.find(params[:id])
    @reviews = @product.reviews.includes(user: { avatar_attachment: :blob }).order(created_at: :desc).page(params[:page]).per(3)
    @bookmarks_by_product_id = current_user.product_bookmarks.index_by(&:product_id)
  end
end
