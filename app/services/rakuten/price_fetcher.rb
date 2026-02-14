require "uri"

module Rakuten
  class PriceFetcher
    def fetch(reference_url)
      normalized_url = reference_url.to_s.strip
      return failure("参照URLが未設定です。", :blank_url) if normalized_url.blank?

      parsed = parse_reference_url(normalized_url)
      return parsed if parsed.is_a?(Hash) && parsed[:ok] == false

      shop_code, item_code = parsed
      items = RakutenWebService::Ichiba::Item.search(
        shopCode: shop_code,
        keyword: item_code,
        hits: 30
      )
      return failure("楽天APIで商品が見つかりませんでした。URL無効または販売終了の可能性があります。", :item_not_found) if items.blank?

      item = find_item_by_url(items, reference_url)
      return failure("楽天API結果とURLが一致しません。URL無効または商品移動の可能性があります。", :url_mismatch) unless item

      price = item["itemPrice"]
      return failure("楽天APIの価格が取得できませんでした。", :missing_price) if price.blank?

      success(price.to_i)
    rescue StandardError => e
      failure("楽天APIエラー: #{e.class}", :api_error)
    end

    private

    def find_item_by_url(items, reference_url)
      target = canonical_item_url(reference_url)
      return nil if target.blank?

      items.find do |it|
        canonical_item_url(it["itemUrl"]) == target
      end
    end

    def canonical_item_url(raw_url)
      uri = URI.parse(raw_url.to_s.strip)
      return nil if uri.host.blank?

      path = uri.path.to_s
      path = "/#{path}" unless path.start_with?("/")
      path = path.sub(%r{/\z}, "")
      host = uri.host.to_s.downcase
      "#{host}#{path}"
    rescue URI::InvalidURIError
      nil
    end

    def parse_reference_url(reference_url)
      uri = URI.parse(reference_url.to_s.strip)
      return failure("楽天の商品URL形式ではありません。", :not_rakuten_item_url) unless uri.host == "item.rakuten.co.jp"

      parts = uri.path.to_s.split("/").reject(&:blank?)
      return failure("楽天の商品URL形式ではありません。", :not_rakuten_item_url) if parts.size < 2

      [ parts[0], parts[1] ]
    rescue URI::InvalidURIError
      failure("参照URLの形式が不正です。", :invalid_url)
    end

    def success(price)
      { ok: true, price: price }
    end

    def failure(error, reason = :unknown)
      { ok: false, error: error, reason: reason }
    end
  end
end
