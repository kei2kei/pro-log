class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :review_likes, dependent: :destroy

  validates :title, presence: true
  validates :overall_score, :sweetness, :richness, :aftertaste, :flavor_score, :solubility, :foam, presence: true
  validates :overall_score, :sweetness, :richness, :aftertaste, :flavor_score, :solubility, :foam,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { scope: :product_id }
end
