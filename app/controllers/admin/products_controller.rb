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

  def bulk_new
    @bulk_common = default_bulk_common
    @bulk_items = default_bulk_items
  end

  def bulk_create
    @bulk_common = bulk_common_params.to_h
    @bulk_items = Array(params.dig(:bulk, :items)).map { |row| row.to_h.symbolize_keys }

    rows = @bulk_items.select { |row| row.values.any?(&:present?) }
    if rows.blank?
      flash.now[:alert] = "フレーバー行を1件以上入力してください。"
      render :bulk_new, status: :unprocessable_entity
      return
    end

    products = []
    row_errors = []

    rows.each_with_index do |row, idx|
      product = Product.new(
        name: @bulk_common["name"],
        brand: @bulk_common["brand"],
        protein_type: @bulk_common["protein_type"],
        flavor: row[:flavor],
        price: row[:price].presence || @bulk_common["default_price"],
        calorie: row[:calorie],
        protein: row[:protein],
        fat: row[:fat],
        carbohydrate: row[:carbohydrate],
        image_url: row[:image_url].presence || @bulk_common["default_image_url"],
        reference_url: row[:reference_url].presence || @bulk_common["default_reference_url"]
      )

      unless product.valid?
        row_errors << "行#{idx + 1}: #{product.errors.full_messages.join(', ')}"
      end

      products << product
    end

    if row_errors.present?
      flash.now[:alert] = row_errors.join(" / ")
      render :bulk_new, status: :unprocessable_entity
      return
    end

    Product.transaction do
      products.each(&:save!)
    end

    redirect_to admin_products_path, notice: "#{products.size}件の商品を登録しました。"
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

  def duplicate
  original = Product.find(params[:id])
  @product = original.dup
  @product.name = "#{original.name}（複製）"

  flash.now[:notice] = "複製元の商品を読み込みました。必要な部分だけ編集してください。"
  render :new
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

  def bulk_common_params
    params.require(:bulk).permit(
      :name,
      :brand,
      :protein_type,
      :default_price,
      :default_image_url,
      :default_reference_url
    )
  end

  def default_bulk_common
    bulk = params[:bulk].presence || {}

    {
      "name" => (bulk[:name] || params[:name]).to_s,
      "brand" => (bulk[:brand] || params[:brand]).to_s,
      "protein_type" => (bulk[:protein_type] || params[:protein_type]).presence_in(Product.protein_types.keys) || "whey",
      "default_price" => (bulk[:default_price] || params[:price]).to_s,
      "default_image_url" => (bulk[:default_image_url] || params[:image_url]).to_s,
      "default_reference_url" => (bulk[:default_reference_url] || params[:reference_url]).to_s
    }
  end

  def default_bulk_items
    bulk = params[:bulk].presence || {}
    items = Array(bulk[:items]).map { |row| row.to_h.symbolize_keys }
    base_count = items.size
    requested_count = bulk[:row_count].to_i
    target_count = [ requested_count, base_count, 5 ].max

    while items.size < target_count
      items << { flavor: "", price: "", calorie: "", protein: "", fat: "", carbohydrate: "", image_url: "", reference_url: "" }
    end

    items
  end

  def require_admin!
    redirect_to root_path, alert: "権限がありません。" unless current_user.admin?
  end
end
