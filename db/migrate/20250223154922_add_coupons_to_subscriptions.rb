class AddCouponsToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_reference :subscriptions, :coupon, null: true, foreign_key: true
  end
end
