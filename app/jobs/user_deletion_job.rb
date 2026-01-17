class UserDeletionJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user&.deleted_at?
    return if user.deleted_at > 30.days.ago

    user.destroy!
  end
end
