require "rails_helper"

RSpec.describe ReviewComment, type: :model do
  describe "associations" do
    it "review と user に紐づく" do
      review_comment = build(:review_comment)

      expect(review_comment.review).to be_present
      expect(review_comment.user).to be_present
    end
  end

  describe "validations" do
    it "body が空だと無効" do
      review_comment = build(:review_comment, body: "")

      expect(review_comment).to be_invalid
      expect(review_comment.errors[:body]).to be_present
    end

    it "body が500文字を超えると無効" do
      review_comment = build(:review_comment, body: "a" * 501)

      expect(review_comment).to be_invalid
      expect(review_comment.errors[:body]).to be_present
    end

    it "body が500文字以内なら有効" do
      review_comment = build(:review_comment, body: "a" * 500)

      expect(review_comment).to be_valid
    end
  end
end
