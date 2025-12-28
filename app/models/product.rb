class Product < ApplicationRecord
  has_one_attached :image
  has_many :reviews, dependent: :destroy
  has_many :product_bookmarks, dependent: :destroy
  has_many :product_taggings, dependent: :destroy
  has_many :tags, through: :product_taggings

  enum :protein_type, {
    whey: 0,
    soy: 1,
    casein: 2,
    blend: 3
  }

  validates :name, :brand, :price, :protein_type, presence: true

  def review_averages
    @review_averages ||= {
      sweetness: reviews.average(:sweetness)&.to_f,
      richness: reviews.average(:richness)&.to_f,
      aftertaste: reviews.average(:aftertaste)&.to_f,
      flavor_score: reviews.average(:flavor_score)&.to_f,
      solubility: reviews.average(:solubility)&.to_f,
      foam: reviews.average(:foam)&.to_f
    }
  end

  def overall_average_score
    reviews.average(:overall_score)&.to_f
  end
end
