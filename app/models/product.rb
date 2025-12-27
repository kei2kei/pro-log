class Product < ApplicationRecord
  has_one_attached :image

  enum :protein_type, {
    whey: 0,
    soy: 1,
    casein: 2,
    blend: 3
  }

  validates :name, :brand, :price, :protein_type, presence: true
end
