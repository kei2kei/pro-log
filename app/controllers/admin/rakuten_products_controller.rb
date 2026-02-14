class Admin::RakutenProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def search
    @keyword = params[:keyword].to_s.strip
    @selected_shop_code = params[:shop_code].presence
    @pages = params[:pages].presence || "1"
    @official_shops = OfficialShop.active.ordered
    @searched = @keyword.present? || @selected_shop_code.present?

    if @searched
      search_keyword = @keyword.presence || "プロテイン"
      @results = Rakuten::SearchService.search_products(
        keyword: search_keyword,
        shop_code: @selected_shop_code,
        pages: @pages
      )
    else
      @results = []
    end
  rescue StandardError => e
    Rails.logger.error("[RakutenSearch] #{e.class}: #{e.message}")
    @results = []
    flash.now[:alert] = "検索に失敗しました。もう一度お試しください。"
  end

  def add_official_shop
    shop = OfficialShop.find_or_initialize_by(shop_code: official_shop_params[:shop_code])
    shop.assign_attributes(
      shop_name: official_shop_params[:shop_name],
      active: true
    )
    shop.save!

    redirect_back fallback_location: search_admin_rakuten_products_path, notice: "公式ショップに追加しました。"
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: search_admin_rakuten_products_path, alert: e.record.errors.full_messages.join(", ")
  end

  private

  def official_shop_params
    params.require(:official_shop).permit(:shop_code, :shop_name)
  end

  def require_admin!
    redirect_to root_path, alert: "権限がありません" unless current_user.admin?
  end
end
