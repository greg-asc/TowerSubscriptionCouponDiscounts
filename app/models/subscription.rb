class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :coupon, optional: true

  # To avoid collisions just in case.
  validates :external_id, uniqueness: true

  # The number of seats needs to be at least 1.
  validates :seats, numericality: { only_integer: true, greater_than: 0 }

  # The unit prices must be non-negative.
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  # The effective price must be non-negative.
  validates :effective_price, numericality: { greater_than_or_equal_to: 0 }


  # Need to set the effective price from unit price at the beginning.
  before_validation :set_effective_price, on: :create


  # Applies coupon and calculates new price in a unitary fashion.
  def apply_coupon(coup)
    return false unless coup&.can_be_applied?

    # Entire process wrapped in a transaction to ensure integrity.
    transaction do
      # If the subscription already had a coupon, remove it first.
      remove_coupon if coupon.present?

      # Apply provided coupon and calculate new effective price.
      self.coupon          = coup
      original_price       = plan.unit_price
      discounted_price     = original_price * (1 - coup.percentage_discount * 0.01)
      self.effective_price = discounted_price

      # Bump up the charges counter.
      coup.increment! :charges_used

      save!
    end

    true

  # This is to catch failed transactions.
  rescue ActiveRecord::RecordInvalid
    false
  end

  # Removes coupon and restores the original unit price.
  def remove_coupon
    return unless coupon.present?

    transaction do
      self.effective_price = unit_price
      coupon.decrement! :charges_used
      self.coupon = nil
      save!
    end
  end

  private


  # Set the effective price of the subscription if not already set.
  def set_effective_price
    self.effective_price ||= unit_price
  end
end
