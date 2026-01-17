class RankingsController < ApplicationController
  def index
    @tab = params[:tab].presence_in(%w[overall bookmark reviews]) || "overall"

    if @tab == "reviews"
      @top_reviewed_products = Product
        .joins(:reviews)
        .select("products.*, COUNT(reviews.id) AS reviews_count")
        .group("products.id")
        .order("reviews_count DESC, products.name ASC")
        .limit(10)
    elsif @tab == "bookmark"
      @top_bookmarked_products = Product
        .joins(:product_bookmarks)
        .select("products.*, COUNT(product_bookmarks.id) AS bookmarks_count")
        .group("products.id")
        .order("bookmarks_count DESC, products.name ASC")
        .limit(10)
    else
      @top_overall_score_products = Product
        .joins(:reviews)
        .select("products.*, AVG(reviews.overall_score) AS avg_score")
        .group("products.id")
        .order("avg_score DESC, products.name ASC")
        .limit(10)
    end
  end
end
