require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:subscription)).to be_valid
    end

    it 'is invalid without a plan' do
      expect(build(:subscription, plan: nil)).not_to be_valid
    end

    it 'is invalid with seats <= 0' do
      expect(build(:subscription, seats: 0)).not_to be_valid
    end

    it 'is invalid with a negative unit_price' do
      expect(build(:subscription, unit_price: -1.00)).not_to be_valid
    end

    it 'is invalid with a negative effective_price' do
      expect(build(:subscription, effective_price: -1.00)).not_to be_valid
    end

    it 'is invalid with a duplicate external_id' do
      sub1 = create(:subscription)
      expect(build(:subscription, external_id: sub1.external_id)).not_to be_valid
    end
  end

  describe 'default effective_price' do
    it 'sets effective_price to unit_price on creation' do
      sub = create(:subscription, unit_price: 20.00)
      expect(sub.effective_price).to eq(20.00)
    end
  end

  describe '#apply_coupon' do
    let(:plan) { create(:plan, unit_price: 20.00) }
    let(:coupon) { create(:coupon, percentage_discount: 25.00, max_charges: 2) }
    let(:subscription) { create(:subscription, plan: plan, unit_price: 20.00) }

    it 'applies the coupon and updates effective_price' do
      expect(subscription.apply_coupon(coupon)).to be true
      expect(subscription.coupon).to eq(coupon)
      expect(subscription.unit_price).to eq(20.00) # Unchanged
      expect(subscription.effective_price).to eq(15.00) # 20.00 - 25%
      expect(coupon.reload.charges_used).to eq(1)
    end

    it 'does not apply if coupon is not can_be_applied' do
      coupon.update(charges_used: 2) # Maxed out
      expect(subscription.apply_coupon(coupon)).to be false
      expect(subscription.coupon).to be_nil
      expect(subscription.effective_price).to eq(20.00)
      expect(coupon.reload.charges_used).to eq(2)
    end

    it 'replaces an existing coupon correctly' do
      old_coupon = create(:coupon, percentage_discount: 10.00, max_charges: 1)
      subscription.apply_coupon(old_coupon)
      subscription.apply_coupon(coupon)
      expect(subscription.coupon).to eq(coupon)
      expect(subscription.effective_price).to eq(15.00)
      expect(old_coupon.reload.charges_used).to eq(0)
      expect(coupon.reload.charges_used).to eq(1)
    end
  end

  describe '#remove_coupon' do
    let(:plan) { create(:plan, unit_price: 20.00) }
    let(:coupon) { create(:coupon, percentage_discount: 25.00, max_charges: 2) }
    let(:subscription) { create(:subscription, plan: plan, unit_price: 20.00) }

    it 'removes the coupon and resets effective_price' do
      subscription.apply_coupon(coupon)
      subscription.remove_coupon
      expect(subscription.coupon).to be_nil
      expect(subscription.unit_price).to eq(20.00)
      expect(subscription.effective_price).to eq(20.00)
      expect(coupon.reload.charges_used).to eq(0)
    end

    it 'does nothing if no coupon is applied' do
      subscription.remove_coupon
      expect(subscription.coupon).to be_nil
      expect(subscription.effective_price).to eq(20.00)
    end
  end
end
