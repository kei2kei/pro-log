require "rails_helper"

RSpec.describe ReviewLike, type: :model do
  describe "ReviewLike#バリデーションチェック" do
    it "同一ユーザーの同一レビューは重複できない" do
      user = create(:user)
      review = create(:review)
      create(:review_like, user: user, review: review)

      duplicate = build(:review_like, user: user, review: review)
      expect(duplicate).not_to be_valid
    end

    it "自分のレビューにはいいねできない" do
      user = create(:user)
      review = create(:review, user: user)

      like = build(:review_like, user: user, review: review)
      expect(like).not_to be_valid
      expect(like.errors.full_messages.join).to include("自分のレビューにはいいねできません")
    end
  end
end
