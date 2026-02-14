require "rails_helper"

RSpec.describe Admin::NutritionSuggestionService, type: :service do
  let(:url) { "https://example.com/item" }

  describe "#call" do
    it "参照URLが空なら失敗する" do
      allow_any_instance_of(described_class).to receive(:openai_api_key).and_return("sk-test")

      result = described_class.new(reference_url: "").call

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("参照URLを入力")
    end

    it "APIキーがない場合は失敗する" do
      allow_any_instance_of(described_class).to receive(:openai_api_key).and_return("")

      result = described_class.new(reference_url: url).call

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("OPENAI_API_KEY")
    end

    it "OpenAIエラー時はエラーメッセージを返す" do
      allow_any_instance_of(described_class).to receive(:openai_api_key).and_return("sk-test")
      allow_any_instance_of(described_class).to receive(:fetch_page_data).and_return({
        ok: true,
        text: "本文",
        flavors: []
      })

      http = instance_double(Net::HTTP)
      bad = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")
      allow(bad).to receive(:body).and_return({ error: { message: "invalid_request" } }.to_json)
      allow(http).to receive(:request).and_return(bad)
      allow(Net::HTTP).to receive(:start).and_yield(http)

      result = described_class.new(reference_url: url).call

      expect(result[:ok]).to eq(false)
      expect(result[:error]).to include("AIの呼び出しに失敗しました")
      expect(result[:error]).to include("400")
      expect(result[:error]).to include("invalid_request")
    end

    it "AI結果とフレーバー候補をマージし、既定栄養素で補完する" do
      allow_any_instance_of(described_class).to receive(:openai_api_key).and_return("sk-test")
      allow_any_instance_of(described_class).to receive(:fetch_page_data).and_return({
        ok: true,
        text: "1食あたり103kcal タンパク質21g 脂質1.9g 炭水化物1g",
        flavors: [ "チョコ", "バニラ" ]
      })

      http = instance_double(Net::HTTP)
      ok = Net::HTTPOK.new("1.1", "200", "OK")
      allow(ok).to receive(:body).and_return({
        output_text: {
          flavors: [
            { flavor: "チョコ", protein: "22" }
          ]
        }.to_json
      }.to_json)
      allow(http).to receive(:request).and_return(ok)
      allow(Net::HTTP).to receive(:start).and_yield(http)

      result = described_class.new(reference_url: url).call

      expect(result[:ok]).to eq(true)
      expect(result[:rows].size).to eq(2)

      choco = result[:rows].find { |r| r[:flavor] == "チョコ" }
      vanilla = result[:rows].find { |r| r[:flavor] == "バニラ" }

      expect(choco[:protein]).to eq("22")
      expect(choco[:calorie]).to eq("103")
      expect(vanilla[:calorie]).to eq("103")
      expect(vanilla[:fat]).to eq("1.9")
      expect(vanilla[:carbohydrate]).to eq("1")
    end

    it "AIのflavorsが空でも本文からフレーバーを抽出できれば成功する" do
      allow_any_instance_of(described_class).to receive(:openai_api_key).and_return("sk-test")
      allow_any_instance_of(described_class).to receive(:fetch_page_data).and_return({
        ok: true,
        text: "チョコ:ホエイプロテイン バニラ:ホエイプロテイン 103kcal タンパク質21g 脂質1.9g 炭水化物1g",
        flavors: []
      })

      http = instance_double(Net::HTTP)
      ok = Net::HTTPOK.new("1.1", "200", "OK")
      allow(ok).to receive(:body).and_return({ output_text: { flavors: [] }.to_json }.to_json)
      allow(http).to receive(:request).and_return(ok)
      allow(Net::HTTP).to receive(:start).and_yield(http)

      result = described_class.new(reference_url: url).call

      expect(result[:ok]).to eq(true)
      expect(result[:rows].map { |r| r[:flavor] }).to include("チョコ", "バニラ")
    end
  end
end
