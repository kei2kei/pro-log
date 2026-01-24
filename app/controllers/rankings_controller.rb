class RankingsController < ApplicationController
  def index
    @tab = params[:tab].presence_in(%w[overall bookmark reviews]) || "overall"

    if @tab == "reviews"
      @top_reviewed_products = Product
        .joins(:product_stat)
        .where("product_stats.reviews_count > 0")
        .order("product_stats.reviews_count DESC, products.name ASC")
        .limit(10)
    elsif @tab == "bookmark"
      @top_bookmarked_products = Product
        .joins(:product_stat)
        .where("product_stats.reviews_count > 0")
        .order("product_stats.bookmarks_count DESC, products.name ASC")
        .limit(10)
    else
      @top_overall_score_products = Product
        .joins(:product_stat)
        .where("product_stats.reviews_count > 0")
        .order("product_stats.avg_overall_score DESC, products.name ASC")
        .limit(10)
    end
  end
end
