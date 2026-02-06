require "rails_helper"

RSpec.describe "いいね", type: :system do
  include ActionView::RecordIdentifier

  let(:user) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:product) { create(:product, name: "Like Target") }
  let(:review) do
    create(:review, user: reviewer, product: product, overall_score: 4, sweetness: 3, richness: 3, aftertaste: 3,
                    flavor_score: 3, solubility: 3, foam: 3, title: "Like Review Title", comment: "コメント")
  end

  before do
    review
    sign_in_as(user)
  end

  describe "いいね登録" do
    it "レビューにいいねできる" do
      visit product_path(product)
      within("turbo-frame##{dom_id(review, :like)}") do
        click_button I18n.t("shared.like.add")
      end

      within("turbo-frame##{dom_id(review, :like)}") do
        expect(page).to have_button(I18n.t("shared.like.saved"))
      end
    end

    it "プロフィールのいいね一覧に反映される" do
      visit product_path(product)
      within("turbo-frame##{dom_id(review, :like)}") do
        click_button I18n.t("shared.like.add")
      end

      visit profile_path(tab: "likes")
      expect(page).to have_content(review.title)
    end
  end

  describe "いいね解除" do
    it "いいねを解除できる" do
      visit product_path(product)
      within("turbo-frame##{dom_id(review, :like)}") do
        click_button I18n.t("shared.like.add")
      end

      within("turbo-frame##{dom_id(review, :like)}") do
        click_button I18n.t("shared.like.saved")
        expect(page).to have_button(I18n.t("shared.like.add"))
      end
    end

    it "プロフィールのいいね一覧から消える" do
      visit product_path(product)
      within("turbo-frame##{dom_id(review, :like)}") do
        click_button I18n.t("shared.like.add")
      end

      within("turbo-frame##{dom_id(review, :like)}") do
        click_button I18n.t("shared.like.saved")
      end

      visit profile_path(tab: "likes")
      expect(page).not_to have_content(review.title)
      expect(page).to have_content(I18n.t("profiles.show.empty.likes"))
    end
  end
end
