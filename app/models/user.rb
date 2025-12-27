class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :reviews, dependent: :destroy
  has_many :product_bookmarks, dependent: :destroy
  has_many :bookmark_products, through: :product_bookmarks, source: :product

  validates :username, presence: true, uniqueness: { case_sensitive: false }
end
