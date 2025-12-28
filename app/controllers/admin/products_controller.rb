class Admin::ProductsController < ApplicationController
  def index
    @products = Product.order(created_at: :desc)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_products_path, notice: "商品を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :brand,
      :protein_type,
      :flavor,
      :price,
      :calorie,
      :protein,
      :fat,
      :carbohydrate,
      :image
    )
  end
end
