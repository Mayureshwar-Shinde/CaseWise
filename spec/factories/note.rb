FactoryBot.define do
  factory :note do
    content { "MyText" }
    user
    association :case_id, factory: :case
  end
end
