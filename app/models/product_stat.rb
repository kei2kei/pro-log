class ProductStat < ApplicationRecord
  belongs_to :product

  def self.refresh_for(product)
    product_id = product.is_a?(Product) ? product.id : product
    return if product_id.blank?
    return unless Product.exists?(id: product_id)

    reviews = Review.where(product_id: product_id)
    aggregates = reviews
      .select(
        "AVG(overall_score) AS avg_overall_score",
        "AVG(sweetness) AS avg_sweetness",
        "AVG(richness) AS avg_richness",
        "AVG(aftertaste) AS avg_aftertaste",
        "AVG(flavor_score) AS avg_flavor_score",
        "AVG(solubility) AS avg_solubility",
        "AVG(foam) AS avg_foam",
        "COUNT(*) AS reviews_count"
      )
      .take

    stats = find_or_initialize_by(product_id: product_id)
    stats.avg_overall_score = aggregates.read_attribute(:avg_overall_score)
    stats.avg_sweetness = aggregates.read_attribute(:avg_sweetness)
    stats.avg_richness = aggregates.read_attribute(:avg_richness)
    stats.avg_aftertaste = aggregates.read_attribute(:avg_aftertaste)
    stats.avg_flavor_score = aggregates.read_attribute(:avg_flavor_score)
    stats.avg_solubility = aggregates.read_attribute(:avg_solubility)
    stats.avg_foam = aggregates.read_attribute(:avg_foam)
    stats.reviews_count = aggregates.read_attribute(:reviews_count)
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
