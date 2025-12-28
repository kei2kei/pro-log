class ReviewTagging < ApplicationRecord
  belongs_to :review
  belongs_to :tag

  validates :review_id, uniqueness: { scope: :tag_id }
end
