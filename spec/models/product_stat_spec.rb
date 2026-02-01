require "rails_helper"

RSpec.describe ProductStat, type: :model do
  describe "ProductStat#集計更新" do
    it "レビューの平均と件数を集計できる" do
      product = create(:product)
      create(:review, product: product, overall_score: 5, sweetness: 4, richness: 3, aftertaste: 2, flavor_score: 4, solubility: 5, foam: 1)
      create(:review, product: product, overall_score: 3, sweetness: 2, richness: 4, aftertaste: 3, flavor_score: 3, solubility: 4, foam: 2)
      create(:product_bookmark, product: product)

      ProductStat.refresh_for(product)
      stat = ProductStat.find_by(product: product)

      expect(stat.reviews_count).to eq(2)
      expect(stat.bookmarks_count).to eq(1)
      expect(stat.avg_overall_score.to_f).to be_within(0.01).of(4.0)
      expect(stat.avg_sweetness.to_f).to be_within(0.01).of(3.0)
    end
  end
end
