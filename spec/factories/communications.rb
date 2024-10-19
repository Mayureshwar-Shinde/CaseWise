FactoryBot.define do
  factory :communication do
    from { nil }
    to { nil }
    subject { "MyString" }
    message { "MyText" }
    association :case_id, factory: :case
  end
end
