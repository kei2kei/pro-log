FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password1" }
    password_confirmation { "Password1" }

    after(:build) do |user|
      user.skip_confirmation!
    end
  end
end
