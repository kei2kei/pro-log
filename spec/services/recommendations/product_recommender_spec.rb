require "rails_helper"

RSpec.describe Recommendations::ProductRecommender, type: :service do
  let(:user) { create(:user) }

  it "レビューがない場合はフォールバックする" do
    product = create(:product, name: "Fallback")
    create(:product_stat, product: product, reviews_count: 0)

    results = described_class.new(user).recommend

    expect(results).to include(product)
  end

  it "ブックマーク済みやレビュー済みの商品は除外される" do
    reviewed = create(:product, name: "Reviewed")
    bookmarked = create(:product, name: "Bookmarked")
    candidate = create(:product, name: "Candidate")

    create(:product_stat, product: reviewed, reviews_count: 3, avg_overall_score: 3.5, avg_sweetness: 3, avg_richness: 3, avg_aftertaste: 3, avg_flavor_score: 3, avg_solubility: 3, avg_foam: 3)
    create(:product_stat, product: bookmarked, reviews_count: 3, avg_overall_score: 3.5, avg_sweetness: 3, avg_richness: 3, avg_aftertaste: 3, avg_flavor_score: 3, avg_solubility: 3, avg_foam: 3)
    create(:product_stat, product: candidate, reviews_count: 3, avg_overall_score: 3.5, avg_sweetness: 3, avg_richness: 3, avg_aftertaste: 3, avg_flavor_score: 3, avg_solubility: 3, avg_foam: 3)

    create(:review, user: user, product: reviewed, overall_score: 3, sweetness: 3, richness: 3, aftertaste: 3, flavor_score: 3, solubility: 3, foam: 3)
    create(:product_bookmark, user: user, product: bookmarked)

    results = described_class.new(user).recommend

    expect(results).to include(candidate)
    expect(results).not_to include(reviewed)
    expect(results).not_to include(bookmarked)
  end

  it "レビュー平均に近い商品が推薦される" do
    preferred = create(:product, name: "Preferred")
    other = create(:product, name: "Other")

    create(:product_stat, product: preferred, reviews_count: 3, avg_overall_score: 5.0, avg_sweetness: 5, avg_richness: 5, avg_aftertaste: 5, avg_flavor_score: 5, avg_solubility: 5, avg_foam: 5)
    create(:product_stat, product: other, reviews_count: 3, avg_overall_score: 1.0, avg_sweetness: 1, avg_richness: 1, avg_aftertaste: 1, avg_flavor_score: 1, avg_solubility: 1, avg_foam: 1)

    3.times do
      create(:review, user: user, product: create(:product), overall_score: 5, sweetness: 5, richness: 5, aftertaste: 5, flavor_score: 5, solubility: 5, foam: 5)
    end

    results = described_class.new(user).recommend(limit: 1)

    expect(results.first).to eq(preferred)
  end
end
