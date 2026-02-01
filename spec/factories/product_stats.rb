FactoryBot.define do
  factory :product_stat do
    association :product
    avg_overall_score { 4.2 }
    avg_sweetness { 3.5 }
    avg_richness { 3.8 }
    avg_aftertaste { 3.2 }
    avg_flavor_score { 3.9 }
    avg_solubility { 4.0 }
    avg_foam { 2.8 }
    reviews_count { 1 }
    bookmarks_count { 0 }
  end
end
