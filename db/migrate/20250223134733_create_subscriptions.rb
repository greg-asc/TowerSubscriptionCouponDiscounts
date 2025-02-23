class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.uuid :external_id, default: 'gen_random_uuid()', null: false
      t.integer :seats
      t.decimal :unit_price, precision: 10, scale: 2
      t.references :plan, null: false, foreign_key: true

      t.timestamps
    end
  end
end
