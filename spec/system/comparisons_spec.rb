require "rails_helper"

RSpec.describe "比較機能", type: :system do
  let(:user) { create(:user) }
  let!(:products) do
    create_list(:product, 4).each_with_index.map do |product, index|
      product.update!(name: "Compare Product #{index + 1}")
      product
    end
  end

  before do
    sign_in_as(user)
  end

  def add_to_compare_from_index(product)
    card = find("h2 a", text: product.name).ancestor("div.rounded-3xl")
    within(card) do
      click_button I18n.t("shared.compare.add")
    end
  end

  describe "比較追加" do
    it "商品一覧から比較対象に追加できる" do
      visit products_path
      add_to_compare_from_index(products.first)

      expect(page).to have_content(I18n.t("shared.compare.tray_count", count: 1))
      expect(page).to have_button(I18n.t("shared.compare.selected"), disabled: true)
    end

    it "3件追加すると4件目は追加できない表示になる" do
      visit products_path
      add_to_compare_from_index(products.first)
      add_to_compare_from_index(products.second)
      add_to_compare_from_index(products.third)

      card = find("h2 a", text: products.fourth.name).ancestor("div.rounded-3xl")
      within(card) do
        click_button I18n.t("shared.compare.add")
        expect(page).to have_button(I18n.t("shared.compare.full"), disabled: true)
      end
      expect(page).to have_content(I18n.t("shared.compare.tray_count", count: 3))
    end
  end

  describe "比較削除" do
    it "トレイから個別削除できる" do
      visit products_path
      add_to_compare_from_index(products.first)
      add_to_compare_from_index(products.second)

      within("#compare_tray") do
        click_button I18n.t("shared.compare.remove"), match: :first
      end

      expect(page).to have_content(I18n.t("shared.compare.tray_count", count: 1))
    end

    it "全クリアで比較対象を空にできる" do
      visit products_path
      add_to_compare_from_index(products.first)
      add_to_compare_from_index(products.second)

      within("#compare_tray") do
        click_button I18n.t("shared.compare.clear")
      end

      expect(page).not_to have_css("#compare_tray .rounded-2xl")
    end
  end

  describe "比較ページ" do
    it "比較ページで選択商品を表示できる" do
      visit products_path
      add_to_compare_from_index(products.first)
      add_to_compare_from_index(products.second)

      within("#compare_tray") do
        click_link I18n.t("shared.compare.open")
      end

      expect(page).to have_content(I18n.t("comparisons.show.title"))
      expect(page).to have_content(products.first.name)
      expect(page).to have_content(products.second.name)
    end
  end
end
