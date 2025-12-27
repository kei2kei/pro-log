class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.with_attached_image.order(created_at: :desc)
  end
end
