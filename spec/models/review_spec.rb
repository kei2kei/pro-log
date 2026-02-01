require "rails_helper"

RSpec.describe Review, type: :model do
  describe "Review#バリデーションチェック" do
    it "正常系の確認" do
      expect(build(:review)).to be_valid
    end

    it "タイトルの必須エラー確認" do
      review = build(:review, title: nil)
      expect(review).not_to be_valid
    end

    it "各スコアが必須であることの確認" do
      review = build(:review, overall_score: nil)
      expect(review).not_to be_valid
    end

    it "スコアが1〜5以外だと無効になる" do
      review = build(:review, overall_score: 6)
      expect(review).not_to be_valid
    end

    it "同一ユーザーは同一商品に複数レビューできない" do
      user = create(:user)
      product = create(:product)
      create(:review, user: user, product: product)

      duplicate = build(:review, user: user, product: product)
      expect(duplicate).not_to be_valid
    end
  end

  describe "Review#tag_names" do
    it "区切り文字付きの入力でタグが割り当てられる" do
      review = create(:review)
      review.tag_names = "Vanilla, Chocolate"
      review.save!

      expect(review.tags.pluck(:name)).to contain_exactly("vanilla", "chocolate")
    end
  end
end
