require "rails_helper"

RSpec.describe RakutenPriceSyncJob, type: :job do
  describe "#perform" do
    it "楽天URLの商品だけを対象に価格を更新する" do
      rakuten_product = create(:product, price: 3000, reference_url: "https://item.rakuten.co.jp/myshop/item001/")
      non_rakuten = create(:product, price: 3500, reference_url: "https://example.com/items/1")
      blank_url = create(:product, price: 3600, reference_url: nil)

      fetcher = instance_double(Rakuten::PriceFetcher)
      allow(Rakuten::PriceFetcher).to receive(:new).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return({ ok: true, price: 4200 })

      result = described_class.perform_now(batch_size: 10)

      expect(result[:total]).to eq(1)
      expect(result[:updated]).to eq(1)
      expect(rakuten_product.reload.price).to eq(4200)
      expect(non_rakuten.reload.price).to eq(3500)
      expect(blank_url.reload.price).to eq(3600)
    end

    it "同額は unchanged として扱う" do
      product = create(:product, price: 3000, reference_url: "https://item.rakuten.co.jp/myshop/item001/")
      fetcher = instance_double(Rakuten::PriceFetcher)
      allow(Rakuten::PriceFetcher).to receive(:new).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return({ ok: true, price: 3000 })

      result = described_class.perform_now(batch_size: 10)

      expect(result[:total]).to eq(1)
      expect(result[:updated]).to eq(0)
      expect(result[:unchanged]).to eq(1)
      expect(product.reload.price).to eq(3000)
    end

    it "フェッチ失敗はスキップして継続する" do
      p1 = create(:product, price: 3000, reference_url: "https://item.rakuten.co.jp/myshop/a/")
      p2 = create(:product, price: 3100, reference_url: "https://item.rakuten.co.jp/myshop/b/")
      fetcher = instance_double(Rakuten::PriceFetcher)
      allow(Rakuten::PriceFetcher).to receive(:new).and_return(fetcher)
      allow(fetcher).to receive(:fetch).and_return(
        { ok: false, error: "not found", reason: :item_not_found },
        { ok: true, price: 3300 }
      )

      result = described_class.perform_now(batch_size: 10)

      expect(result[:total]).to eq(2)
      expect(result[:skipped]).to eq(1)
      expect(result[:updated]).to eq(1)
      expect(result[:skip_reasons]).to eq({ "item_not_found" => 1 })
      expect(p1.reload.price).to eq(3000)
      expect(p2.reload.price).to eq(3300)
    end
  end
end
