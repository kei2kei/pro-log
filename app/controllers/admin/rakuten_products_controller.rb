class Admin::RakutenProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def search
    @keyword = params[:keyword]

    if @keyword.present?
      @results = Rakuten::SearchService.search_products(keyword: @keyword)
    else
      @results = []
    end
  rescue StandardError => e
    Rails.logger.error("[RakutenSearch] #{e.class}: #{e.message}")
    @results = []
    flash.now[:alert] = "検索に失敗しました。もう一度お試しください。"
  end

  private

  def require_admin!
    redirect_to root_path, alert: "権限がありません" unless current_user.admin?
  end
end
