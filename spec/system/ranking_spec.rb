require "rails_helper"

RSpec.describe "ランキング", type: :system do
  let(:product_a) { create(:product, name: "Rank A") }
  let(:product_b) { create(:product, name: "Rank B") }

  before do
    create(:product_stat, product: product_a, avg_overall_score: 4.8, bookmarks_count: 5, reviews_count: 3)
    create(:product_stat, product: product_b, avg_overall_score: 3.5, bookmarks_count: 1, reviews_count: 2)
  end

  it "ヘッダーからランキング画面に遷移できる" do
    visit root_path
    click_link I18n.t("shared.header.nav.ranking")

    expect(page).to have_content(I18n.t("rankings.index.title"))
  end

  it "総合満足度ランキングが見られる" do
    visit ranking_path

    expect(page).to have_content(I18n.t("rankings.index.tab_overall"))
    expect(page).to have_content("Rank A")
  end

  it "ブックマーク数ランキングが見られる" do
    visit ranking_path(tab: "bookmark")

    expect(page).to have_content(I18n.t("rankings.index.tab_bookmark"))
    expect(page).to have_content("Rank A")
  end

  it "レビュー数ランキングが見られる" do
    visit ranking_path(tab: "reviews")

    expect(page).to have_content(I18n.t("rankings.index.tab_reviews"))
    expect(page).to have_content("Rank A")
  end
end
