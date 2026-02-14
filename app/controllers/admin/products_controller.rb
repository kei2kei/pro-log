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

  def bulk_suggest
    permitted_bulk = bulk_params
    @bulk_common = permitted_bulk.slice(
      "name",
      "brand",
      "protein_type",
      "default_price",
      "default_image_url",
      "default_reference_url"
    )
    @bulk_items = default_bulk_items_from(permitted_bulk)

    result = Admin::NutritionSuggestionService.new(
      reference_url: @bulk_common["default_reference_url"]
    ).call

    unless result[:ok]
      if request.format.json?
        render json: { ok: false, error: result[:error] }, status: :unprocessable_entity
      else
        flash.now[:alert] = result[:error]
        render :bulk_new, status: :unprocessable_entity
      end
      return
    end

    ai_rows = result[:rows]
    ai_rows.each_with_index do |row, idx|
      target = (@bulk_items[idx] || {}).symbolize_keys
      target[:flavor] = row[:flavor]
      target[:calorie] = row[:calorie]
      target[:protein] = row[:protein]
      target[:fat] = row[:fat]
      target[:carbohydrate] = row[:carbohydrate]
      target[:reference_url] = @bulk_common["default_reference_url"] if target[:reference_url].blank?
      @bulk_items[idx] = target
    end

    while @bulk_items.size < [ ai_rows.size, 5 ].max
      @bulk_items << { flavor: "", price: "", calorie: "", protein: "", fat: "", carbohydrate: "", image_url: "", reference_url: "" }
    end

    first_flavor = ai_rows.first&.dig(:flavor).to_s
    message = "AI補完を実行しました。#{ai_rows.size}件のフレーバー情報を補完しました（先頭: #{first_flavor.presence || 'なし'}）。必要に応じて修正してから一括登録してください。"
    if request.format.json?
      render json: {
        ok: true,
        message: message,
        rows: @bulk_items.map(&:to_h)
      }
    else
      flash.now[:notice] = message
      render :bulk_new
    end
  end

  def bulk_create
    permitted_bulk = bulk_params
    @bulk_common = permitted_bulk.slice(
      "name",
      "brand",
      "protein_type",
      "default_price",
      "default_image_url",
      "default_reference_url"
    )
    @bulk_items = extract_bulk_items(permitted_bulk["items"])

    rows = []
    row_errors = []

    @bulk_items.each_with_index do |row, idx|
      next if row.values.all?(&:blank?)

      if row[:flavor].blank?
        row_errors << "行#{idx + 1}: フレーバーは必須です。"
        next
      end

      missing_fields = []
      missing_fields << "カロリー" if row[:calorie].blank?
      missing_fields << "タンパク質(P)" if row[:protein].blank?
      missing_fields << "脂質(F)" if row[:fat].blank?
      missing_fields << "炭水化物(C)" if row[:carbohydrate].blank?
      if missing_fields.present?
        row_errors << "行#{idx + 1}: #{missing_fields.join('、')}は必須です。"
        next
      end

      rows << [ row, idx ]
    end

    if rows.blank? && row_errors.blank?
      flash.now[:alert] = "フレーバー行を1件以上入力してください。"
      render :bulk_new, status: :unprocessable_entity
      return
    end

    products = []

    rows.each do |row, idx|
      product = Product.new(
        name: @bulk_common["name"],
        brand: @bulk_common["brand"],
        protein_type: @bulk_common["protein_type"],
        flavor: row[:flavor].to_s.strip,
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
        next
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

  def bulk_params
    params.require(:bulk).permit(
      :name,
      :brand,
      :protein_type,
      :default_price,
      :default_image_url,
      :default_reference_url,
      :row_count,
      items: [ :flavor, :price, :calorie, :protein, :fat, :carbohydrate, :image_url, :reference_url ]
    )
  end

  def default_bulk_common
    bulk = safe_bulk_new_params

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
    bulk = safe_bulk_new_params
    items = extract_bulk_items(bulk[:items] || bulk["items"])
    base_count = items.size
    requested_count = bulk[:row_count].to_i
    target_count = [ requested_count, base_count, 5 ].max

    while items.size < target_count
      items << { flavor: "", price: "", calorie: "", protein: "", fat: "", carbohydrate: "", image_url: "", reference_url: "" }
    end

    items
  end

  def default_bulk_items_from(permitted_bulk)
    items = extract_bulk_items(permitted_bulk["items"])
    target_count = [ items.size, permitted_bulk["row_count"].to_i, 5 ].max
    while items.size < target_count
      items << { flavor: "", price: "", calorie: "", protein: "", fat: "", carbohydrate: "", image_url: "", reference_url: "" }
    end
    items
  end

  def safe_bulk_new_params
    raw = params[:bulk]
    return {} unless raw.present?

    if raw.is_a?(ActionController::Parameters)
      raw.permit(
        :name,
        :brand,
        :protein_type,
        :default_price,
        :default_image_url,
        :default_reference_url,
        :row_count,
        items: [ :flavor, :price, :calorie, :protein, :fat, :carbohydrate, :image_url, :reference_url ]
      )
    else
      {}
    end
  end

  def extract_bulk_items(raw_items)
    rows =
      case raw_items
      when ActionController::Parameters
        raw_items.to_h.values
      when Hash
        raw_items.values
      when Array
        raw_items
      else
        []
      end

    rows.map do |row|
      case row
      when ActionController::Parameters
        row.to_h.symbolize_keys
      when Hash
        row.symbolize_keys
      else
        {}
      end
    end
  end

  def require_admin!
    redirect_to root_path, alert: "権限がありません。" unless current_user.admin?
  end
end
