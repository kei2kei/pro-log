FactoryBot.define do
  factory :product_bookmark do
    association :user
    association :product
  end
end
