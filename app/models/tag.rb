class Tag < ApplicationRecord
  has_many :review_taggings, dependent: :destroy
  has_many :reviews, through: :review_taggings
  has_many :product_taggings, dependent: :destroy
  has_many :products, through: :product_taggings

  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.normalize_names(value)
    value.to_s.split(/[,\s]+/).map { |name| name.strip.downcase }.reject(&:blank?).uniq
  end

  private

  # 単体保存用
  def normalize_name
    self.name = name.to_s.strip.downcase
  end
end
