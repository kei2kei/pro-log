class ChangeNutritionColumnsToDecimal < ActiveRecord::Migration[8.1]
  def change
    change_column :products, :protein,      :decimal, precision: 5, scale: 2
    change_column :products, :fat,          :decimal, precision: 5, scale: 2
    change_column :products, :carbohydrate, :decimal, precision: 5, scale: 2
  end
end
