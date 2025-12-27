class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :brand
      t.integer :price
      t.string :flavor
      t.integer :protein_type
      t.integer :calorie
      t.integer :protein
      t.integer :fat
      t.integer :carbohydrate

      t.timestamps
    end
  end
end
