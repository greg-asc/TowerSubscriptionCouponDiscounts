class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.integer :max_charges, null: false
      t.integer :charges_used, null: false, default: 0
      t.decimal :percentage_discount, null: false, precision: 5, scale: 2

      t.timestamps
    end
  end
end
