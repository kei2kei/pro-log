class CreateReviewTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :review_taggings do |t|
      t.references :review, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
