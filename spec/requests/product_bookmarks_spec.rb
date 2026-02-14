require "rails_helper"

RSpec.describe "ProductBookmarks", type: :request do
  def turbo_headers
    { "ACCEPT" => "text/vnd.turbo-stream.html" }
  end

  describe "POST /bookmarks" do
    it "ブックマークが作成できる" do
      user = create(:user)
      product = create(:product)
      sign_in user, scope: :user

      expect {
        post bookmarks_path, params: { product_id: product.id }
      }.to change(ProductBookmark, :count).by(1)

      expect(response).to redirect_to(product_path(product))
    end

    it "既存ブックマークがある場合は重複作成しない" do
      user = create(:user)
      product = create(:product)
      create(:product_bookmark, user: user, product: product)
      sign_in user, scope: :user

      expect {
        post bookmarks_path, params: { product_id: product.id }
      }.not_to change(ProductBookmark, :count)

      expect(response).to redirect_to(product_path(product))
    end

    it "turbo_stream でブックマーク作成できる" do
      user = create(:user)
      product = create(:product)
      sign_in user, scope: :user

      post bookmarks_path, params: { product_id: product.id }, headers: turbo_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("bookmark_product_#{product.id}")
    end

    it "turbo_stream で作成失敗時は422を返す" do
      user = create(:user)
      product = create(:product)
      sign_in user, scope: :user
      allow_any_instance_of(ProductBookmark).to receive(:save).and_return(false)

      post bookmarks_path, params: { product_id: product.id }, headers: turbo_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("ブックマークに失敗しました")
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
      sign_in user, scope: :user

      expect {
        delete bookmark_path(bookmark), headers: { "HTTP_REFERER" => product_path(product) }
      }.to change(ProductBookmark, :count).by(-1)

      expect(response).to redirect_to(product_path(product))
    end

    it "turbo_stream でブックマーク解除できる" do
      user = create(:user)
      product = create(:product)
      bookmark = create(:product_bookmark, user: user, product: product)
      sign_in user, scope: :user

      delete bookmark_path(bookmark), headers: turbo_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("bookmark_product_#{product.id}")
    end

    it "turbo_stream で解除失敗時は422を返す" do
      user = create(:user)
      product = create(:product)
      bookmark = create(:product_bookmark, user: user, product: product)
      sign_in user
      allow_any_instance_of(ProductBookmark).to receive(:destroy).and_return(false)

      delete bookmark_path(bookmark), headers: turbo_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("ブックマーク解除に失敗しました")
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
