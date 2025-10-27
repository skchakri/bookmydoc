FactoryBot.define do
  factory :message do
    sender { nil }
    receiver { nil }
    content { "MyText" }
    read_at { "2025-10-26 17:48:36" }
  end
end
