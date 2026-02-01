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
  end
end
