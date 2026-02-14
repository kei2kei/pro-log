require "rails_helper"

RSpec.describe "Admin::RakutenProducts", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in admin
  end

  describe "GET /admin/rakuten_products/search" do
    it "検索ページを表示できる" do
      get search_admin_rakuten_products_path
      expect(response).to have_http_status(:ok)
    end

    it "検索時にサービス結果を表示し、登録済み情報も出せる" do
      create(:product, reference_url: "https://item.rakuten.co.jp/x/y", flavor: "チョコ")
      allow(Rakuten::SearchService).to receive(:search_products).and_return(
        [
          {
            name: "楽天商品",
            url: "https://item.rakuten.co.jp/x/y",
            image_url: "https://example.com/image.jpg",
            price: 1999,
            shop_name: "公式ショップ",
            shop_code: "shop123"
          }
        ]
      )

      get search_admin_rakuten_products_path, params: { keyword: "whey", pages: "1" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("楽天商品")
      expect(response.body).to include("登録済み")
    end

    it "検索サービスが例外ならエラーメッセージを表示する" do
      allow(Rakuten::SearchService).to receive(:search_products).and_raise(StandardError.new("boom"))

      get search_admin_rakuten_products_path, params: { keyword: "whey" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("検索に失敗しました")
    end
  end

  describe "POST /admin/rakuten_products/add_official_shop" do
    it "公式ショップを追加できる" do
      expect {
        post add_official_shop_admin_rakuten_products_path,
             params: { official_shop: { shop_code: "myshop", shop_name: "My Shop" } }
      }.to change(OfficialShop, :count).by(1)

      expect(response).to redirect_to(search_admin_rakuten_products_path)
      expect(flash[:notice]).to include("公式ショップに追加")
    end

    it "不正値なら追加失敗しalertを返す" do
      expect {
        post add_official_shop_admin_rakuten_products_path,
             params: { official_shop: { shop_code: "myshop", shop_name: "" } }
      }.not_to change(OfficialShop, :count)

      expect(response).to redirect_to(search_admin_rakuten_products_path)
      expect(flash[:alert]).to be_present
    end
  end
end
