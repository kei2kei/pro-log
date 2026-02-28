FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    association :actor, factory: :user
    association :notifiable, factory: :review_comment
    read_at { nil }
  end
end
