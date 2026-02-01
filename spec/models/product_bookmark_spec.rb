require "rails_helper"

RSpec.describe ProductBookmark, type: :model do
  describe "ProductBookmark#バリデーションチェック" do
    it "同一ユーザーの同一商品は重複できない" do
      user = create(:user)
      product = create(:product)
      create(:product_bookmark, user: user, product: product)

      duplicate = build(:product_bookmark, user: user, product: product)
      expect(duplicate).not_to be_valid
    end
  end
end
