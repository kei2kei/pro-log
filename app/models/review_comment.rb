class ReviewComment < ApplicationRecord
  belongs_to :review
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 500 }
end
