class ProductStatRefreshJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    ProductStat.refresh_for(product_id)
  end
end
