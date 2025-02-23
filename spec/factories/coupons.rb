FactoryBot.define do
  factory :coupon do
    code { "SAVE#{rand(1000..9999)}" } # Unique code
    percentage_discount { 25.00 }
    max_charges { 3 }
  end
end
