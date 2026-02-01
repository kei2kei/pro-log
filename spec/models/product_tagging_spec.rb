require "rails_helper"

RSpec.describe ProductTagging, type: :model do
  describe "ProductTagging#バリデーションチェック" do
    it "同一商品の同一タグは重複できない" do
      product = create(:product)
      tag = create(:tag)
      create(:product_tagging, product: product, tag: tag)

      duplicate = build(:product_tagging, product: product, tag: tag)
      expect(duplicate).not_to be_valid
    end
  end
end
