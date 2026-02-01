require "rails_helper"

RSpec.describe ReviewTagging, type: :model do
  describe "ReviewTagging#バリデーションチェック" do
    it "同一レビューの同一タグは重複できない" do
      review = create(:review)
      tag = create(:tag)
      create(:review_tagging, review: review, tag: tag)

      duplicate = build(:review_tagging, review: review, tag: tag)
      expect(duplicate).not_to be_valid
    end
  end
end
