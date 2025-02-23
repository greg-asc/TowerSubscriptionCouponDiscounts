require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:plan)).to be_valid
    end

    it 'is invalid without a title' do
      expect(build(:plan, title: nil)).not_to be_valid
    end

    it 'is invalid with a negative unit_price' do
      expect(build(:plan, unit_price: -1.00)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many subscriptions' do
      plan = create(:plan)
      create(:subscription, plan: plan)
      expect(plan.subscriptions.count).to eq(1)
    end
  end
end
