require "rails_helper"

RSpec.describe Rakuten::PriceFetcher, type: :service do
  describe "#fetch" do
    it "楽天URLでなければ失敗する" do
      result = described_class.new.fetch("https://example.com/item/1")

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("楽天の商品URL形式")
      expect(result[:reason]).to eq(:not_rakuten_item_url)
    end

    it "URL形式が不正なら失敗する" do
      result = described_class.new.fetch("https://%zz")

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("形式が不正")
      expect(result[:reason]).to eq(:invalid_url)
    end

    it "商品が取得できれば価格を返す" do
      allow(RakutenWebService::Ichiba::Item).to receive(:search).and_return(
        [ { "itemPrice" => 3980, "itemUrl" => "https://item.rakuten.co.jp/myshop/abc123/" } ]
      )

      result = described_class.new.fetch("https://item.rakuten.co.jp/myshop/abc123/")

      expect(result).to eq({ ok: true, price: 3980 })
      expect(RakutenWebService::Ichiba::Item).to have_received(:search).with(
        shopCode: "myshop",
        keyword: "abc123",
        hits: 30
      )
    end

    it "楽天API例外時は失敗として返す" do
      allow(RakutenWebService::Ichiba::Item).to receive(:search).and_raise(StandardError.new("timeout"))

      result = described_class.new.fetch("https://item.rakuten.co.jp/myshop/abc123/")

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("楽天APIエラー")
      expect(result[:reason]).to eq(:api_error)
    end

    it "検索結果が空なら失敗する" do
      allow(RakutenWebService::Ichiba::Item).to receive(:search).and_return([])

      result = described_class.new.fetch("https://item.rakuten.co.jp/myshop/abc123/")

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("商品が見つかりません")
      expect(result[:reason]).to eq(:item_not_found)
    end

    it "URL完全一致する商品が見つからない場合は失敗する" do
      allow(RakutenWebService::Ichiba::Item).to receive(:search).and_return(
        [ { "itemPrice" => 3980, "itemUrl" => "https://item.rakuten.co.jp/myshop/other-item/" } ]
      )

      result = described_class.new.fetch("https://item.rakuten.co.jp/myshop/abc123/")

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("URLが一致しません")
      expect(result[:reason]).to eq(:url_mismatch)
    end
  end
end
