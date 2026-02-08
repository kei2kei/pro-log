require "rails_helper"

RSpec.describe "ブックマーク", type: :system do
  let(:user) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:product) { create(:product, name: "Bookmark Target") }

  before do
    create(:review, user: reviewer, product: product, overall_score: 4, sweetness: 3, richness: 3, aftertaste: 3, flavor_score: 3, solubility: 3, foam: 3, title: "レビュー", comment: "コメント")
    sign_in_as(user)
  end

  describe "ブックマーク登録" do
    it "商品詳細からブックマークできる" do
      visit product_path(product)
      find("button[aria-label='#{I18n.t('shared.bookmark.add')}']").click

      expect(page).to have_button(I18n.t("shared.bookmark.saved"), exact: false)
    end

    it "プロフィールのブックマーク一覧に反映される" do
      visit product_path(product)
      find("button[aria-label='#{I18n.t('shared.bookmark.add')}']").click

      visit profile_path(tab: "bookmarks")
      expect(page).to have_content(product.name)
    end
  end

  describe "ブックマーク解除" do
    it "ブックマークを解除できる" do
      visit product_path(product)
      find("button[aria-label='#{I18n.t('shared.bookmark.add')}']").click

      find("button[aria-label='#{I18n.t('shared.bookmark.remove')}']").click
      expect(page).to have_button(I18n.t("shared.bookmark.add"))
    end

    it "プロフィールのブックマーク一覧から消える" do
      visit product_path(product)
      find("button[aria-label='#{I18n.t('shared.bookmark.add')}']").click

      find("button[aria-label='#{I18n.t('shared.bookmark.remove')}']").click

      visit profile_path(tab: "bookmarks")
      expect(page).not_to have_content(product.name)
    end
  end
end
