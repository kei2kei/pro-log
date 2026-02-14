require "rails_helper"

RSpec.describe "Product#商品一覧と詳細", type: :system do
  context "ログイン前" do
    it "商品一覧にアクセスできる" do
      visit products_path

      expect(page).to have_content(I18n.t("products.index.title"))
    end

    it "商品詳細ではレビュー作成・ブックマーク・いいねボタンが表示されない" do
      product = create(:product, name: "Guest Hidden Controls")
      reviewer = create(:user)
      create(:review, user: reviewer, product: product, title: "Guest review")

      visit product_path(product)

      expect(page).not_to have_link(I18n.t("products.show.review_cta"))
      expect(page).not_to have_selector("button[aria-label='#{I18n.t('shared.bookmark.add')}']")
      expect(page).not_to have_selector("button[aria-label='#{I18n.t('shared.like.add')}']")
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
      detail_link = find("a[href='#{product_path(product)}']", match: :first)
      detail_link.click
      page.execute_script("arguments[0].click()", detail_link.native) if page.current_path == products_path

      expect(page).to have_current_path(product_path(product), ignore_query: true)
      expect(page).to have_content(I18n.t("products.show.title"))
      expect(page).to have_content(product.name)
    end

    it "おすすめカードから詳細へ遷移できる" do
      product = create(:product, name: "Recommended Product")

      allow(Recommendations::ProductRecommender).to receive(:new)
        .and_return(instance_double(Recommendations::ProductRecommender, recommend: [ product ]))

      visit root_path
      click_link product.name

      expect(page).to have_current_path(product_path(product), ignore_query: true)
      expect(page).to have_content(I18n.t("products.show.title"))
      expect(page).to have_content(product.name)
    end

    it "未レビュー商品の詳細ではレビュー作成ボタンが表示される" do
      product = create(:product, name: "NoReviewProduct")

      visit product_path(product)

      expect(page).to have_link(I18n.t("products.show.review_cta"))
    end

    it "レビュー済み商品の詳細ではレビュー作成ボタンが表示されない" do
      product = create(:product, name: "ReviewedProduct")
      create(:review, product: product, user: user)

      visit product_path(product)

      expect(page).not_to have_link(I18n.t("products.show.review_cta"))
    end
  end
end
