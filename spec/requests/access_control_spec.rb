require "rails_helper"

RSpec.describe "ログイン後公開ページのアクセスチェック", type: :request do
  describe "認証必須ページ" do
    it "商品一覧は未ログインでも表示できる" do
      get products_path
      expect(response).to have_http_status(:ok)
    end

    it "商品詳細は未ログインでも表示できる" do
      product = create(:product)
      get product_path(product)
      expect(response).to have_http_status(:ok)
    end

    it "レビュー詳細は未ログインでも表示できる" do
      review = create(:review)
      get review_path(review)
      expect(response).to have_http_status(:ok)
    end

    it "レビュー作成画面はログイン必須" do
      product = create(:product)
      get new_product_review_path(product)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "マイページはログイン必須" do
      get profile_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
