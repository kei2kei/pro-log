require "rails_helper"

RSpec.describe Product, type: :model do
  describe "Product#バリデーションチェック" do
    it "正常系の確認" do
      expect(build(:product)).to be_valid
    end

    it "商品名の必須エラー確認" do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
    end

    it "ブランド名の必須エラー確認" do
      product = build(:product, brand: nil)
      expect(product).not_to be_valid
    end

    it "価格の必須エラー確認" do
      product = build(:product, price: nil)
      expect(product).not_to be_valid
    end

    it "プロテインタイプの必須エラー確認" do
      product = build(:product, protein_type: nil)
      expect(product).not_to be_valid
    end
  end

  describe "Product#tag_names" do
    it "区切り文字付きの入力でタグが割り当てられる" do
      product = create(:product)
      product.tag_names = "Vanilla, Chocolate"
      product.save!

      expect(product.tags.pluck(:name)).to contain_exactly("vanilla", "chocolate")
    end

    it "タグ名が文字列として返る" do
      product = create(:product)
      product.tag_names = "strawberry"
      product.save!

      expect(product.tag_names).to include("strawberry")
    end
  end
end
