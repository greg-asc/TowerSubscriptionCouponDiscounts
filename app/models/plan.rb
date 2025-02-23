class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :title, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
end
