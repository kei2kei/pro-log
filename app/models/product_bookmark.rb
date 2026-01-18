class ProductBookmark < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :user_id, uniqueness: { scope: :product_id }

  after_commit :enqueue_product_stats_refresh, on: %i[create destroy]

  private

  def enqueue_product_stats_refresh
    ProductStatRefreshJob.perform_later(product_id)
  end
end
