class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :title, null: false
      t.text :comment
      t.integer :overall_score, null: false
      t.integer :sweetness, null: false
      t.integer :richness, null: false
      t.integer :aftertaste, null: false
      t.integer :flavor_score, null: false
      t.integer :solubility, null: false
      t.integer :foam, null: false

      t.timestamps
    end
  end
end
