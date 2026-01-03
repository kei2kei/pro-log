class Admin::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_product, only: [ :edit, :update, :destroy ]

  def index
    @products = Product.order(created_at: :desc)
  end

  def new
    @product = Product.new(
      params.permit(
        :name,
        :brand,
        :flavor,
        :price,
        :reference_url,
        :image_url
      )
    )
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_products_path, notice: "商品を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "商品を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, alert: "商品を削除しました。"
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :brand, :flavor, :protein_type,
      :price, :calorie, :protein, :fat, :carbohydrate,
      :reference_url,
      :image_url
    )
  end

  def require_admin!
    redirect_to root_path, alert: "権限がありません。" unless current_user.admin?
  end
end
