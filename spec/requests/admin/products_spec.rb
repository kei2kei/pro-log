require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in admin
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
end
