class CreateProductTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :product_taggings do |t|
      t.references :product, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    add_index :product_taggings, [:product_id, :tag_id], unique: true
  end
end
