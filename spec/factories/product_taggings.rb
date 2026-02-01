FactoryBot.define do
  factory :product_tagging do
    association :product
    association :tag
  end
end
