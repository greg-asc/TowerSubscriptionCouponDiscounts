require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:coupon)).to be_valid
    end

    it 'is invalid without a code' do
      expect(build(:coupon, code: nil)).not_to be_valid
    end

    it 'is invalid with a duplicate code' do
      create(:coupon, code: 'SAVE25')
      expect(build(:coupon, code: 'SAVE25')).not_to be_valid
    end

    it 'is invalid with a percentage_discount <= 0' do
      expect(build(:coupon, percentage_discount: 0)).not_to be_valid
    end

    it 'is invalid with a percentage_discount > 100' do
      expect(build(:coupon, percentage_discount: 101.00)).not_to be_valid
    end

    it 'is invalid with a max_charges <= 0' do
      expect(build(:coupon, max_charges: 0)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many subscriptions' do
      coupon = create(:coupon)
      create(:subscription, coupon: coupon)
      expect(coupon.subscriptions.count).to eq(1)
    end
  end

  describe '#remaining_charges' do
    it 'calculates remaining charges correctly' do
      coupon = create(:coupon, max_charges: 3, charges_used: 1)
      expect(coupon.remaining_charges).to eq(2)
    end
  end

  describe '#can_be_applied?' do
    it 'returns true if remaining charges > 0' do
      coupon = create(:coupon, max_charges: 3, charges_used: 2)
      expect(coupon.can_be_applied?).to be true
    end

    it 'returns false if remaining charges <= 0' do
      coupon = create(:coupon, max_charges: 3, charges_used: 3)
      expect(coupon.can_be_applied?).to be false
    end
  end

  describe 'immutability' do
    let(:coupon) { create(:coupon) }
    let(:subscription) { create(:subscription) }

    it 'prevents updates if applied to a subscription' do
      subscription.apply_coupon(coupon)
      coupon.percentage_discount = 30.00
      expect(coupon.save).to be false
      expect(coupon.errors[:base]).to include("Cannot edit a coupon that has been applied to subscription(s)")
    end

    it 'prevents deletion if applied to a subscription' do
      subscription.apply_coupon(coupon)
      expect(coupon.destroy).to be false
      expect(coupon.errors[:base]).to include("Cannot delete a coupon that has been applied to subscription(s)")
    end

    it 'allows updates if not applied' do
      coupon.percentage_discount = 30.00
      expect(coupon.save).to be true
    end

    it 'allows deletion if not applied' do
      expect(coupon.destroy).to eq coupon
    end
  end
end
