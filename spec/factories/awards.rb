FactoryBot.define do
  factory :award do
    doctor { nil }
    title { "MyString" }
    issuing_organization { "MyString" }
    date_received { "2025-10-26" }
    description { "MyText" }
  end
end
