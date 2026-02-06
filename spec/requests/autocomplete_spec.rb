require "rails_helper"

RSpec.describe "オートコンプリートAPI", type: :request do
  describe "GET /autocomplete/tags" do
    it "空クエリはタグ一覧を返す" do
      create(:tag, name: "Alpha")
      create(:tag, name: "Beta")

      get autocomplete_tags_path

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include("alpha", "beta")
    end

    it "クエリに一致するタグのみ返す" do
      create(:tag, name: "Vanilla")
      create(:tag, name: "Chocolate")

      get autocomplete_tags_path, params: { q: "Van" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to eq([ "vanilla" ])
    end
  end

  describe "GET /autocomplete/search" do
    it "空クエリは空配列を返す" do
      get autocomplete_search_path, params: { q: "" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "商品名・ブランド・フレーバー・タグから候補を返す" do
      create(:product, name: "Alpha", brand: "BrandX", flavor: "Lemon")
      create(:tag, name: "AlphaTag")

      get autocomplete_search_path, params: { q: "Alpha" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include("Alpha")
      expect(body).to include("alphatag")
    end
  end
end
