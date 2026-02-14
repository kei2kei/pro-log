class CreateOfficialShops < ActiveRecord::Migration[8.1]
  def change
    create_table :official_shops do |t|
      t.string :shop_code, null: false
      t.string :shop_name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :official_shops, :shop_code, unique: true
    add_index :official_shops, :active
  end
end
