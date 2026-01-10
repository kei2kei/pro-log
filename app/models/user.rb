class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one_attached :avatar

  has_many :reviews, dependent: :destroy
  has_many :product_bookmarks, dependent: :destroy
  has_many :bookmark_products, through: :product_bookmarks, source: :product
  has_many :review_likes, dependent: :destroy
  has_many :like_reviews, through: :review_likes, source: :review

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def like(review)
    like_reviews << review
  end

  def unlike(review)
    like_reviews.destroy(review)
  end

  def like?(review)
    like_reviews.exists?(review.id)
  end
end
