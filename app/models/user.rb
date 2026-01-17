class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_one_attached :avatar

  has_many :reviews, dependent: :destroy
  has_many :product_bookmarks, dependent: :destroy
  has_many :bookmark_products, through: :product_bookmarks, source: :product
  has_many :review_likes, dependent: :destroy
  has_many :like_reviews, through: :review_likes, source: :review

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  def active_for_authentication?
    super && deleted_at.nil?
  end

  def inactive_message
    deleted_at? ? :deleted_account : super
  end

  def like(review)
    like_reviews << review
  end

  def unlike(review)
    like_reviews.destroy(review)
  end

  def like?(review)
    like_reviews.exists?(review.id)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = build_unique_username(auth)
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  # ユーザーネームに一意制約があるためGoogleアカウント名が被った場合はemailの前半部もしくは連番で対応
  def self.build_unique_username(auth)
    base = auth.info.name.presence || auth.info.email.to_s.split("@").first
    base = "user" if base.blank?
    base = base.strip
    candidate = base
    suffix = 1
    while User.where("LOWER(username) = ?", candidate.downcase).exists?
      candidate = "#{base}_#{suffix}"
      suffix += 1
    end
    candidate
  end
end
