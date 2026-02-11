require "rails_helper"

RSpec.describe "Comparisons", type: :request do
  let(:user) { create(:user) }
  let(:products) { create_list(:product, 4) }

  def add_items_to_compare(items)
    items.each { |item| post compare_items_path(product_id: item.id) }
  end

  describe "POST /compare/items" do
    context "ログイン前" do
      it "ログイン画面へリダイレクトされる" do
        post compare_items_path(product_id: products.first.id)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン後" do
      before { sign_in user }

      it "比較対象を追加できる" do
        post compare_items_path(product_id: products.first.id)

        expect(session[:compare_product_ids]).to eq([ products.first.id ])
      end

      it "同一商品は重複追加されない" do
        2.times { post compare_items_path(product_id: products.first.id) }

        expect(session[:compare_product_ids]).to eq([ products.first.id ])
      end

      it "4件目は追加されない（最大3件）" do
        products.each { |product| post compare_items_path(product_id: product.id) }

        expect(session[:compare_product_ids]).to eq(products.first(3).map(&:id))
        expect(flash[:alert]).to eq(I18n.t("shared.compare.limit_alert"))
      end

      it "turbo_streamで応答できる" do
        post compare_items_path(product_id: products.first.id), headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "DELETE /compare/items/:product_id" do
    before { sign_in user }

    it "比較対象を1件削除できる" do
      add_items_to_compare(products.first(2))

      delete compare_item_path(product_id: products.first.id)

      expect(session[:compare_product_ids]).to eq([ products.second.id ])
    end

    it "turbo_streamで応答できる" do
      add_items_to_compare(products.first(2))

      delete compare_item_path(product_id: products.first.id), headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end
  end

  describe "DELETE /compare" do
    before { sign_in user }

    it "比較対象を全クリアできる" do
      add_items_to_compare(products.first(3))

      delete compare_path

      expect(session[:compare_product_ids]).to be_nil
    end
  end

  describe "GET /compare" do
    context "ログイン前" do
      it "ログイン画面へリダイレクトされる" do
        get compare_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン後" do
      before { sign_in user }

      it "比較ページを表示できる" do
        add_items_to_compare(products.first(2))

        get compare_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
