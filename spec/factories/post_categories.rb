FactoryBot.define do
  factory :post_category do
    post_type
    sequence(:name) { |n| "Категория #{n}" }
  end
end
