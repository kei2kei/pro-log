FactoryBot.define do
  factory :review_comment do
    association :review
    association :user
    body { "これはレビューコメントです。" }
  end
end
