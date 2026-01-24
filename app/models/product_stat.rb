class ProductStat < ApplicationRecord
  belongs_to :product

  def self.refresh_for(product)
    product_id = product.is_a?(Product) ? product.id : product
    reviews = Review.where(product_id: product_id)

    stats = find_or_initialize_by(product_id: product_id)
    stats.avg_overall_score = reviews.average(:overall_score)
    stats.avg_sweetness = reviews.average(:sweetness)
    stats.avg_richness = reviews.average(:richness)
    stats.avg_aftertaste = reviews.average(:aftertaste)
    stats.avg_flavor_score = reviews.average(:flavor_score)
    stats.avg_solubility = reviews.average(:solubility)
    stats.avg_foam = reviews.average(:foam)
    stats.reviews_count = reviews.count
    stats.bookmarks_count = ProductBookmark.where(product_id: product_id).count
    stats.save!
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      avg_overall_score
      avg_sweetness
      avg_richness
      avg_aftertaste
      avg_flavor_score
      avg_solubility
      avg_foam
      reviews_count
      bookmarks_count
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
