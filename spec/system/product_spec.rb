require "rails_helper"

RSpec.describe "Product#商品一覧と詳細", type: :system do
  context "ログイン前" do
    it "商品一覧にアクセスできない" do
      visit products_path

      expect(page).to have_content(I18n.t("devise.views.sessions.new.title"))
    end
  end

  context "ログイン後" do
    let(:user) { create(:user) }

    before do
      sign_in_as(user)
    end

    it "ヘッダーから一覧に遷移できる" do
      product = create(:product, name: "System Product")

      visit root_path
      click_link I18n.t("shared.header.nav.products")

      expect(page).to have_content(I18n.t("products.index.title"))
      expect(page).to have_content(product.name)
    end

    it "一覧から詳細へ遷移できる" do
      product = create(:product, name: "List Product")

      visit products_path
      click_link product.name

      expect(page).to have_content(I18n.t("products.show.title"))
      expect(page).to have_content(product.name)
    end

    it "おすすめカードから詳細へ遷移できる" do
      product = create(:product, name: "Recommended Product")

      allow(Recommendations::ProductRecommender).to receive(:new)
        .and_return(instance_double(Recommendations::ProductRecommender, recommend: [ product ]))

      visit root_path
      click_link product.name

      expect(page).to have_content(I18n.t("products.show.title"))
      expect(page).to have_content(product.name)
    end
  end
end
