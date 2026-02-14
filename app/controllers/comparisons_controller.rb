class ComparisonsController < ApplicationController
  def add
    @product = Product.find(params[:product_id])
    ids = compared_product_ids
    added = false

    if !ids.include?(@product.id) && ids.size < 3
      ids << @product.id
      added = true
    end

    session[:compare_product_ids] = ids

    respond_to do |format|
      format.turbo_stream do
        if !added && !ids.include?(@product.id)
          flash.now[:alert] = t("shared.compare.limit_alert")
        end
      end
      format.html do
        if !added && !ids.include?(@product.id)
          redirect_back fallback_location: products_path, alert: t("shared.compare.limit_alert")
        else
          redirect_back fallback_location: products_path
        end
      end
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
