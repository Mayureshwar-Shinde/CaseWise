FactoryBot.define do
  factory :case do
    case_number { "##{SecureRandom.hex(3).upcase}" }
    title { Faker::Lorem.sentences(number: 1)[0] }
    description { Faker::Lorem.paragraph(sentence_count: 20) }
    status { 'open' }
    assigned_to { association :user }
    user { association :user, role_type: 'case_manager' }
  end
end
