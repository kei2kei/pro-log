module Rakuten
  class SearchService
    def self.search_products(keyword:)
      RakutenWebService::Ichiba::Item.search(
        keyword: keyword,
        hits: 20,
        availability: 1
      ).map do |item|
        {
          name: item["itemName"],
          url: item["itemUrl"],
          image_url: item["mediumImageUrls"]&.first,
          price: item["itemPrice"],
          shop: item["shopName"]
        }
      end
    end
  end
end
