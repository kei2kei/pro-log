FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Protein #{n}" }
    sequence(:brand) { |n| "Brand #{n}" }
    price { 3000 }
    protein_type { :whey }
    flavor { "チョコ" }
  end
end
