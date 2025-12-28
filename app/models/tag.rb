class Tag < ApplicationRecord
  has_many :review_taggings, dependent: :destroy
  has_many :reviews, through: :review_taggings
  has_many :product_taggings, dependent: :destroy
  has_many :products, through: :product_taggings
end
