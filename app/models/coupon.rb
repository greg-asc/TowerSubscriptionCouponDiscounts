class Coupon < ApplicationRecord
  # The subscriptions the coupon is applied to.
  has_many :subscriptions, dependent: :restrict_with_error


  # Coupon code, e.g. SAVE10
  validates :code, presence: true, uniqueness: true

  # Percentage discount, e.g. 10.00%
  validates :percentage_discount, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  # Maximum charges allowed on the coupon.
  validates :max_charges, numericality: { only_integer: true, greater_than: 0 }

  # The number of times the coupon has already been applied.
  validates :charges_used, numericality: { only_integer: true, greater_than_or_equal_to: 0 }


  # Making the coupon read-only if it has been applied.
  before_update :prevent_edits_if_applied

  # Not allowed to delete a coupon if applied anywhere.
  before_destroy :prevent_deletion_if_applied


  # Remaining charges as the difference of maximum charges and charges used.
  def remaining_charges
    max_charges - charges_used
  end

  # Checks if the coupon can be applied.
  def can_be_applied?
    remaining_charges > 0
  end


  private


  # Validation code for read-only when applied.
  def prevent_edits_if_applied
    if subscriptions.present?
      errors.add(:base, 'Cannot edit a coupon that has been applied to subscription(s)')
      throw :abort
    end
  end

  # Validation code for delete unless applied.
  def prevent_deletion_if_applied
    if subscriptions.present?
      errors.add(:base, 'Cannot delete a coupon that has been applied to subscription(s)')
      throw :abort
    end
  end
end
