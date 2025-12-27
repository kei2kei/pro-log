class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :title
      t.text :comment
      t.integer :overall_score
      t.integer :sweetness
      t.integer :richness
      t.integer :aftertaste
      t.integer :flavor_score
      t.integer :solubility
      t.integer :foam

      t.timestamps
    end
  end
end
