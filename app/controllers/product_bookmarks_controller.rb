class ProductBookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    bookmark = current_user.product_bookmarks.find_or_create_by!(product: product)

    respond_to do |format|
      format.turbo_stream do
        render "product_bookmarks/update", locals: { product: product, bookmark: bookmark }
      end
      format.html { redirect_back fallback_location: product_path(product), notice: "ブックマークしました。" }
    end
  end

  def destroy
    bookmark = current_user.product_bookmarks.find(params[:id])
    product = bookmark.product
    bookmark.destroy

    respond_to do |format|
      format.turbo_stream do
        render "product_bookmarks/update", locals: { product: product, bookmark: nil }
      end
      format.html { redirect_back fallback_location: product_path(product), notice: "ブックマークを解除しました。" }
    end
  end
end
