FactoryBot.define do
  factory :post_image do
    post
    caption { "MyString" }
    image { "MyString" }
    image_alt_text { "MyString" }
    description { "MyText" }
    source_name { "MyString" }
    source_link { "MyString" }
  end
end
