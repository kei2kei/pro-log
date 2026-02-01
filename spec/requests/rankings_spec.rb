require "rails_helper"

RSpec.describe "ランキング", type: :request do
  describe "GET /ranking" do
    it "空データ時は空表示になる" do
      get ranking_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("rankings.index.empty_state"))
    end

    it "総合満足度タブで商品が表示される" do
      product = create(:product, name: "ScoreTop")
      create(:product_stat, product: product, reviews_count: 3, avg_overall_score: 4.5)

      get ranking_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ScoreTop")
    end

    it "ブックマーク数タブで商品が表示される" do
      product = create(:product, name: "BookmarkTop")
      create(:product_stat, product: product, reviews_count: 2, bookmarks_count: 10)

      get ranking_path(tab: "bookmark")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("BookmarkTop")
    end

    it "レビュー数タブで商品が表示される" do
      product = create(:product, name: "ReviewTop")
      create(:product_stat, product: product, reviews_count: 8)

      get ranking_path(tab: "reviews")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ReviewTop")
    end
  end
end
