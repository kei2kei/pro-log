class CreateReviewLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :review_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true

      t.timestamps
    end
  end
end
