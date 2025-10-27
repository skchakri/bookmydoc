FactoryBot.define do
  factory :unavailable_date do
    doctor { nil }
    date { "2025-10-26" }
    reason { "MyString" }
    is_recurring { false }
  end
end
