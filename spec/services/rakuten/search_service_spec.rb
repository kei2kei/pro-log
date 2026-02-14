require "rails_helper"

RSpec.describe Rakuten::SearchService, type: :service do
  describe ".search_products" do
    it "ページングして重複URLを除去し、画像URLを正規化する" do
      page1 = [
        {
          "itemName" => "A",
          "itemUrl" => "https://example.com/a",
          "largeImageUrls" => [ { "imageUrl" => "https://img.example.com/a.jpg?_ex=128x128" } ],
          "itemPrice" => 1000,
          "shopName" => "Shop",
          "shopCode" => "myshop"
        }
      ]
      page2 = [
        {
          "itemName" => "A duplicate",
          "itemUrl" => "https://example.com/a",
          "largeImageUrls" => [ { "imageUrl" => "https://img.example.com/a.jpg?_ex=128x128" } ],
          "itemPrice" => 1000,
          "shopName" => "Shop",
          "shopCode" => "myshop"
        },
        {
          "itemName" => "B",
          "itemUrl" => "https://example.com/b",
          "mediumImageUrls" => [ "https://img.example.com/b.jpg?_ex=64x64" ],
          "itemPrice" => 2000,
          "shopName" => "Shop",
          "shopCode" => "myshop"
        }
      ]

      allow(RakutenWebService::Ichiba::Item).to receive(:search).and_return(page1, page2)
      allow(described_class).to receive(:sleep)

      result = described_class.search_products(keyword: "whey", shop_code: "myshop", pages: 2)

      expect(result.size).to eq(2)
      expect(result.map { |r| r[:url] }).to contain_exactly("https://example.com/a", "https://example.com/b")
      expect(result.first[:image_url]).to include("_ex=600x600")
      expect(RakutenWebService::Ichiba::Item).to have_received(:search).twice
      expect(described_class).to have_received(:sleep).once
    end

    it "pagesは1..MAX_PAGESにクランプされる" do
      allow(RakutenWebService::Ichiba::Item).to receive(:search).and_return([])
      allow(described_class).to receive(:sleep)

      described_class.search_products(keyword: "whey", pages: 99)

      expect(RakutenWebService::Ichiba::Item).to have_received(:search).exactly(3).times
      expect(described_class).to have_received(:sleep).exactly(2).times
    end
  end
end
