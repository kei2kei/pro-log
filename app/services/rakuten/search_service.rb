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
          image_url: begin
            img = item["largeImageUrls"]&.first || item["mediumImageUrls"]&.first
            url = img.is_a?(Hash) ? img["imageUrl"] : img
            url&.gsub(/_ex=\d+x\d+/, "_ex=600x600")
          end,
          price: item["itemPrice"],
          shop: item["shopName"]
        }
      end
    end
  end
end
