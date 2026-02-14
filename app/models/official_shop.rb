class OfficialShop < ApplicationRecord
  validates :shop_code, presence: true, uniqueness: true
  validates :shop_name, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:shop_name, :shop_code) }
end
