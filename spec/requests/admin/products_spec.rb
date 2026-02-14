require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in admin
  end

  def bulk_payload(items:)
    {
      bulk: {
        row_count: "5",
        name: "Impact Whey",
        brand: "MyProtein",
        protein_type: "whey",
        default_price: "3990",
        default_image_url: "https://example.com/default.jpg",
        default_reference_url: "https://example.com/item",
        items: items
      }
    }
  end

  describe "GET /admin/products" do
    it "一覧を表示できる" do
      get admin_products_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/products/new" do
    it "新規作成画面を表示できる" do
      get new_admin_product_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/products/:id/duplicate" do
    it "複製元を読み込んでnewを表示する" do
      product = create(:product, name: "Original")

      get duplicate_admin_product_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("複製元の商品を読み込みました")
      expect(response.body).to include("Original（複製）")
    end
  end

  describe "POST /admin/products/bulk_create" do
    it "有効な行を一括登録できる" do
      expect {
        post bulk_create_admin_products_path, params: bulk_payload(
          items: {
            "0" => {
              flavor: "チョコ",
              price: "",
              calorie: "103.5",
              protein: "21.0",
              fat: "1.9",
              carbohydrate: "1.0",
              image_url: "",
              reference_url: ""
            }
          }
        )
      }.to change(Product, :count).by(1)

      expect(response).to redirect_to(admin_products_path)
      product = Product.order(:id).last
      expect(product.name).to eq("Impact Whey")
      expect(product.price.to_i).to eq(3990)
      expect(product.image_url).to eq("https://example.com/default.jpg")
      expect(product.reference_url).to eq("https://example.com/item")
      expect(product.calorie.to_s).to include("103.5")
    end

    it "空行のみなら422で再表示する" do
      post bulk_create_admin_products_path, params: bulk_payload(
        items: {
          "0" => {
            flavor: "",
            price: "",
            calorie: "",
            protein: "",
            fat: "",
            carbohydrate: "",
            image_url: "",
            reference_url: ""
          }
        }
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("フレーバー行を1件以上入力してください")
    end

    it "必須栄養素が欠ける行は422でエラー表示する" do
      post bulk_create_admin_products_path, params: bulk_payload(
        items: {
          "0" => {
            flavor: "バニラ",
            price: "3200",
            calorie: "",
            protein: "",
            fat: "1.0",
            carbohydrate: "2.0",
            image_url: "",
            reference_url: ""
          }
        }
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("カロリー")
      expect(response.body).to include("タンパク質(P)")
    end
  end
end
