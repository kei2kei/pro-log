class CreateProductStats < ActiveRecord::Migration[8.1]
  def change
    create_table :product_stats do |t|
      t.references :product, null: false, foreign_key: true
      t.decimal :avg_overall_score
      t.decimal :avg_sweetness
      t.decimal :avg_richness
      t.decimal :avg_aftertaste
      t.decimal :avg_flavor_score
      t.decimal :avg_solubility
      t.decimal :avg_foam
      t.integer :reviews_count, null: false, default: 0
      t.integer :bookmarks_count, null: false, default: 0

      t.timestamps
    end
  end
end
