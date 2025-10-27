FactoryBot.define do
  factory :review do
    doctor { nil }
    patient { nil }
    rating { 1 }
    comment { "MyText" }
  end
end
