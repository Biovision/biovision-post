FactoryBot.define do
  factory :post_image do
    post nil
    visible false
    priority 1
    caption "MyString"
    image "MyString"
    image_alt_text "MyString"
    description "MyText"
    owner_name "MyString"
    owner_link "MyString"
  end
end
