class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    return unless follower_id.present? && followed_id.present?
    return unless follower_id == followed_id

    errors.add(:base, "自分自身はフォローできません。")
  end
end
