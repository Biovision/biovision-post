FactoryBot.define do
  factory :editorial_member do
    user nil
    visible false
    priority 1
    title "MyString"
    lead "MyText"
    about "MyText"
  end
end
