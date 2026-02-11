class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def add
    @product = Product.find(params[:product_id])
    ids = compared_product_ids
    ids << @product.id unless ids.include?(@product.id)
    session[:compare_product_ids] = ids

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: products_path }
    end
  end

  def remove
    @product = Product.find_by(id: params[:product_id])
    ids = compared_product_ids
    ids.delete(params[:product_id].to_i)
    session[:compare_product_ids] = ids

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to params[:return_to].presence || compare_path }
    end
  end

  def clear
    session.delete(:compare_product_ids)
    redirect_back fallback_location: products_path
  end
end
