class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.with_attached_image.order(created_at: :desc)
    @bookmarks_by_product_id = current_user.product_bookmarks.index_by(&:product_id)
  end

  def show
    @product = Product.with_attached_image.find(params[:id])
    @reviews = @product.reviews.includes(user: { avatar_attachment: :blob }).order(created_at: :desc)
    @bookmarks_by_product_id = current_user.product_bookmarks.index_by(&:product_id)
  end
end
