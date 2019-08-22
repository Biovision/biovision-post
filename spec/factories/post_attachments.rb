FactoryBot.define do
  factory :post_attachment do
    post { nil }
    file { "MyString" }
    name { "MyString" }
    uuid { "" }
  end
end
