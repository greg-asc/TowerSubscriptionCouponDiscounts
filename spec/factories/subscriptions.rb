FactoryBot.define do
  factory :subscription do
    association :plan
    seats { 5 }
    unit_price { plan&.unit_price }
  end
end
