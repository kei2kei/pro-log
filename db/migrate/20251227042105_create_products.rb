class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :brand, null: false
      t.integer :price, null: false
      t.string :flavor
      t.integer :protein_type, null: false, default: 0
      t.integer :calorie
      t.integer :protein
      t.integer :fat
      t.integer :carbohydrate

      t.timestamps
    end
  end
end
