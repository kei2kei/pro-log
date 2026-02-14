module Rakuten
  class SearchService
    MAX_HITS = 30
    MAX_PAGES = 3

    def self.search_products(keyword:, shop_code: nil, pages: 1)
      target_pages = pages.to_i.clamp(1, MAX_PAGES)
      all_items = []

      (1..target_pages).each do |page|
        options = {
          keyword: keyword,
          hits: MAX_HITS,
          page: page,
          availability: 1
        }
        options[:shopCode] = shop_code if shop_code.present?

        RakutenWebService::Ichiba::Item.search(options).each do |item|
          all_items << {
            name: item["itemName"],
            url: item["itemUrl"],
            image_url: begin
              img = item["largeImageUrls"]&.first || item["mediumImageUrls"]&.first
              url = img.is_a?(Hash) ? img["imageUrl"] : img
              url&.gsub(/_ex=\d+x\d+/, "_ex=600x600")
            end,
            price: item["itemPrice"],
            shop_name: item["shopName"],
            shop_code: item["shopCode"]
          }
        end

        sleep(1.05) if page < target_pages
      end

      all_items.uniq { |item| item[:url] }
    end
  end
end
