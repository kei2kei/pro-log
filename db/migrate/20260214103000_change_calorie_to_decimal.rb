class ChangeCalorieToDecimal < ActiveRecord::Migration[8.1]
  def change
    change_column :products, :calorie, :decimal, precision: 6, scale: 2
  end
end
