require "rails_helper"

RSpec.describe "レビュー", type: :system do
  let(:product) { create(:product, name: "Review Target") }

  context "ログイン前" do
    it "レビュー作成画面にアクセスできない" do
      visit new_product_review_path(product)

      expect(page).to have_content(I18n.t("devise.views.sessions.new.title"))
    end

    it "レビュー詳細は閲覧できる" do
      reviewer = create(:user)
      review = create(:review, user: reviewer, product: product, title: "公開レビュー", comment: "公開コメント")

      visit review_path(review)

      expect(page).to have_content("公開レビュー")
      expect(page).to have_content("公開コメント")
    end
  end

  context "ログイン後" do
    let(:user) { create(:user) }

    before do
      sign_in_as(user)
    end

    it "商品詳細からレビュー一覧を確認できる" do
      review = create(:review, user: user, product: product, title: "一覧テスト", comment: "コメント")

      visit product_path(product)

      expect(page).to have_content(I18n.t("products.show.reviews_title"))
      expect(page).to have_content(review.title)
    end

    it "レビュー一覧から詳細へ遷移できる" do
      review = create(:review, user: user, product: product, title: "詳細テスト", comment: "コメント")

      visit product_path(product)
      click_link review.title

      expect(page).to have_content(I18n.t("reviews.show.title", username: user.username))
      expect(page).to have_content(review.title)
    end

    describe "レビュー作成" do
      context "正常系" do
        it "レビューを作成できる" do
          visit product_path(product)
          click_link I18n.t("products.show.review_cta")

          find("label[for='review_overall_score_5']").click
          fill_in "review[title]", with: "とても良い"
          fill_in "review[comment]", with: "飲みやすかったです。"

          find("input[name='review[sweetness]']").set(4)
          find("input[name='review[richness]']").set(4)
          find("input[name='review[aftertaste]']").set(3)
          find("input[name='review[flavor_score]']").set(4)
          find("input[name='review[solubility]']").set(4)
          find("input[name='review[foam]']").set(3)

          click_button I18n.t("reviews.form.submit")

          expect(page).to have_content("とても良い")
          expect(page).to have_content("飲みやすかったです。")
          expect(page).to have_link(I18n.t("reviews.show.share.cta"), href: /twitter\.com\/intent\/tweet/)
        end
      end

      context "異常系" do
        it "異常系: 必須項目が不足していると作成できない" do
          visit new_product_review_path(product)

          click_button I18n.t("reviews.form.submit")

          expect(page).to have_content("入力内容をご確認ください")
        end
      end
    end

    describe "レビュー編集" do
      it "レビューを編集できる" do
        review = create(:review, user: user, product: product, title: "編集前", comment: "コメント")

        visit review_path(review)
        click_link I18n.t("reviews.show.actions.edit")

        fill_in "review[title]", with: "編集後"
        click_button I18n.t("reviews.form.submit")

        expect(page).to have_content("編集後")
      end
    end

    describe "レビュー削除" do
      it "レビューを削除できる" do
        review = create(:review, user: user, product: product, title: "削除テスト", comment: "コメント")

        visit review_path(review)
        click_button I18n.t("reviews.show.actions.delete")

        expect(page).to have_current_path(product_path(product), ignore_query: true)
        expect(page).not_to have_content("削除テスト")
      end
    end
  end
end
