FactoryBot.define do
  factory :appointment do
    association :case_id, factory: :case
    case_manager { association :user, role_type: 'case_manager' }
    dispute_analyst { association :user }
    time { "2024-10-05 22:31:45" }
    status { 1 }
  end
end
