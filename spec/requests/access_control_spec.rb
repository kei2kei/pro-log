require "rails_helper"

RSpec.describe "ログイン後公開ページのアクセスチェック", type: :request do
  describe "認証必須ページ" do
    it "商品一覧はログイン必須" do
      get products_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "商品詳細はログイン必須" do
      product = create(:product)
      get product_path(product)
      expect(response).to redirect_to(new_user_session_path)
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
