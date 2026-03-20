module NotificationsHelper
  def notification_message(notification)
    actor_name = notification.actor.username

    case notification.notifiable
    when Review
      "#{actor_name}さんが新しいレビューを投稿しました"
    when ReviewComment
      "#{actor_name}さんがあなた宛にコメントしました"
    when ReviewLike
      "#{actor_name}さんがあなたのレビューにいいねしました"
    when Follow
      "#{actor_name}さんがあなたをフォローしました"
    else
      "#{actor_name}さんから通知があります"
    end
  end

  def notification_link_path(notification)
    case notification.notifiable
    when Review
      review_path(notification.notifiable)
    when ReviewComment
      review_path(notification.notifiable.review)
    when ReviewLike
      review_path(notification.notifiable.review)
    when Follow
      notifications_path
    else
      notifications_path
    end
  rescue ActionController::UrlGenerationError
    notifications_path
  end
end
