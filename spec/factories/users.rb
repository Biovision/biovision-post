FactoryBot.define do
  factory :user do
    sequence(:screen_name) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'secret'
    password_confirmation 'secret'
  end
end
