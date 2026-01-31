class ProductBookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    bookmark = current_user.product_bookmarks.find_or_initialize_by(product: product)

    if bookmark.persisted? || bookmark.save
      respond_to do |format|
        format.turbo_stream do
          render "product_bookmarks/update", locals: { product: product, bookmark: bookmark }
        end
        format.html { redirect_back fallback_location: product_path(product), notice: "ブックマークしました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "ブックマークに失敗しました。"
          render turbo_stream: [
            turbo_stream.replace(
              view_context.dom_id(product, :bookmark),
              partial: "shared/bookmark_button",
              locals: { product: product, bookmark: nil }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ], status: :unprocessable_entity
        end
        format.html do
          redirect_back fallback_location: product_path(product),
                        alert: "ブックマークに失敗しました。"
        end
      end
    end
  end

  def destroy
    bookmark = current_user.product_bookmarks.find(params[:id])
    product = bookmark.product
    if bookmark.destroy
      respond_to do |format|
        format.turbo_stream do
          render "product_bookmarks/update", locals: { product: product, bookmark: nil }
        end
        format.html { redirect_back fallback_location: product_path(product), notice: "ブックマークを解除しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "ブックマーク解除に失敗しました。"
          render turbo_stream: [
            turbo_stream.replace(
              view_context.dom_id(product, :bookmark),
              partial: "shared/bookmark_button",
              locals: { product: product, bookmark: bookmark }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ], status: :unprocessable_entity
        end
        format.html do
          redirect_back fallback_location: product_path(product),
                        alert: "ブックマーク解除に失敗しました。"
        end
      end
    end
  end
end
