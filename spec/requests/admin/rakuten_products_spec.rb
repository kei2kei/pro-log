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
  end
end
