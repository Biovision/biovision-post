FactoryGirl.define do
  factory :post do
    user
    post_type
    title 'Очередная публикация'
    body 'Здесь какой-то текст'
  end
end
