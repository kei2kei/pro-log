FactoryBot.define do
  factory :review do
    association :user
    association :product
    title { "溶けやすくて美味しい" }
    comment { "毎朝の習慣にしています。" }
    overall_score { 4 }
    sweetness { 3 }
    richness { 4 }
    aftertaste { 3 }
    flavor_score { 4 }
    solubility { 4 }
    foam { 2 }
  end
end
