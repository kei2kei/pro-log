class CreateProductBookmarks < ActiveRecord::Migration[8.1]
  def change
    create_table :product_bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
    add_index :product_bookmarks, [ :user_id, :product_id ], unique: true
  end
end
