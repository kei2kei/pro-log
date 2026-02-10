class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def add
    product = Product.find(params[:product_id])
    ids = compared_product_ids
    ids << product.id unless ids.include?(product.id)
    session[:compare_product_ids] = ids
    redirect_back fallback_location: products_path
  end
end
