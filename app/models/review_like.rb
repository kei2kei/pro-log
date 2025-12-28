class ReviewLike < ApplicationRecord
  belongs_to :user
  belongs_to :review

  validates :user_id, uniqueness: { scope: :review_id }
  validate :author_cannot_like_own_review

  private

  def author_cannot_like_own_review
    return if review.blank? || user.blank?
    return if review.user_id != user_id

    errors.add(:base, "自分のレビューにはいいねできません。")
  end
end
