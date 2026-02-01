FactoryBot.define do
  factory :review_tagging do
    association :review
    association :tag
  end
end
