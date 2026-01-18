class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :review_likes, dependent: :destroy
  has_many :review_taggings, dependent: :destroy
  has_many :tags, through: :review_taggings

  validates :title, presence: true
  validates :overall_score, :sweetness, :richness, :aftertaste, :flavor_score, :solubility, :foam, presence: true
  validates :overall_score, :sweetness, :richness, :aftertaste, :flavor_score, :solubility, :foam,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { scope: :product_id }

  after_commit :enqueue_product_stats_refresh, on: %i[create update destroy]

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

  def self.ransackable_attributes(_ = nil)
    %w[overall_score product_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[product]
  end

  private

  def enqueue_product_stats_refresh
    ProductStatRefreshJob.perform_later(product_id)
  end
end
