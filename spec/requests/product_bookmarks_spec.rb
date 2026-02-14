require "rails_helper"

RSpec.describe "ProductBookmarks", type: :request do
  describe "POST /bookmarks" do
    it "ブックマークが作成できる" do
      user = create(:user)
      product = create(:product)
      sign_in user

      expect {
        post bookmarks_path, params: { product_id: product.id }
      }.to change(ProductBookmark, :count).by(1)

      expect(response).to redirect_to(product_path(product))
    end

    it "未ログインではブックマークを作成できない" do
      product = create(:product)

      expect {
        post bookmarks_path, params: { product_id: product.id }
      }.not_to change(ProductBookmark, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "DELETE /bookmarks/:id" do
    it "ブックマークを解除できる" do
      user = create(:user)
      product = create(:product)
      bookmark = create(:product_bookmark, user: user, product: product)
      sign_in user

      expect {
        delete bookmark_path(bookmark), headers: { "HTTP_REFERER" => product_path(product) }
      }.to change(ProductBookmark, :count).by(-1)

      expect(response).to redirect_to(product_path(product))
    end

    it "未ログインではブックマークを解除できない" do
      user = create(:user)
      product = create(:product)
      bookmark = create(:product_bookmark, user: user, product: product)

      expect {
        delete bookmark_path(bookmark), headers: { "HTTP_REFERER" => product_path(product) }
      }.not_to change(ProductBookmark, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
