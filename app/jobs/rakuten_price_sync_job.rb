class RakutenPriceSyncJob < ApplicationJob
  queue_as :default

  def perform(batch_size: 300)
    fetcher = Rakuten::PriceFetcher.new
    targets = Product.where.not(reference_url: [ nil, "" ])
                     .where("reference_url LIKE ? OR reference_url LIKE ?", "https://item.rakuten.co.jp/%", "http://item.rakuten.co.jp/%")

    skip_reasons = Hash.new(0)
    stats = { total: 0, updated: 0, unchanged: 0, skipped: 0, failed: 0 }

    targets.find_each(batch_size: batch_size) do |product|
      stats[:total] += 1
      result = fetcher.fetch(product.reference_url)

      unless result[:ok]
        stats[:skipped] += 1
        reason = result[:reason].to_s.presence || "unknown"
        skip_reasons[reason] += 1
        Rails.logger.warn("[RakutenPriceSyncJob] skip product_id=#{product.id} reason_code=#{reason} reason=#{result[:error]}")
        next
      end

      new_price = result[:price].to_i
      if product.price == new_price
        stats[:unchanged] += 1
        next
      end

      if product.update(price: new_price)
        stats[:updated] += 1
      else
        stats[:failed] += 1
        Rails.logger.error("[RakutenPriceSyncJob] update_failed product_id=#{product.id} errors=#{product.errors.full_messages.join(', ')}")
      end
    rescue StandardError => e
      stats[:failed] += 1
      Rails.logger.error("[RakutenPriceSyncJob] error product_id=#{product.id} error=#{e.class} message=#{e.message}")
    end

    stats[:skip_reasons] = skip_reasons.sort.to_h
    Rails.logger.info("[RakutenPriceSyncJob] finished total=#{stats[:total]} updated=#{stats[:updated]} unchanged=#{stats[:unchanged]} skipped=#{stats[:skipped]} failed=#{stats[:failed]} skip_reasons=#{stats[:skip_reasons].inspect}")
    stats
  end
end
