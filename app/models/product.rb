class Product < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :product_bookmarks, dependent: :destroy
  has_many :product_taggings, dependent: :destroy
  has_many :tags, through: :product_taggings
  has_one :product_stat, dependent: :destroy

  enum :protein_type, {
    whey: 0,
    soy: 1,
    casein: 2,
    blend: 3
  }

  validates :name, :brand, :price, :protein_type, presence: true

  def tag_names
    # フォーム表示用にキャッシュ格納
    @tag_names ||= tags.pluck(:name).join(" ")
  end

  def tag_names=(names)
    # tag_namesにキャッシュ(入力ページに戻った時用)として現在のタグを保持
    @tag_names = names
    normalized = Tag.normalize_names(names)
    self.tags = normalized.map { |name| Tag.find_or_create_by!(name: name) }
  end

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

  ransacker :reviews_overall_score_avg do
    Arel.sql(<<~SQL)
      (
        SELECT AVG(reviews.overall_score)
        FROM reviews
        WHERE reviews.product_id = products.id
      )
    SQL
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      name
      brand
      flavor
      price
      protein_type
      reviews_overall_score_avg
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[reviews tags]
  end
end
