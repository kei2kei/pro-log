class AddRakutenFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :image_url, :string
    add_column :products, :reference_url, :string
  end
end
