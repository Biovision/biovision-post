FactoryBot.define do
  factory :post_type do
    sequence(:name) { |n| "Тип #{n}" }
    sequence(:slug) { |n| "post_type_#{n}"}
  end
end
