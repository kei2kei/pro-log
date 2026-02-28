require "rails_helper"

RSpec.describe "Notifications", type: :request do
  describe "GET /notifications" do
    it "ログインユーザーの通知一覧を表示できる" do
      user = create(:user)
      other_user = create(:user)
      comment = create(:review_comment, user: other_user)
      create(:notification, recipient: user, actor: other_user, notifiable: comment)
      sign_in user, scope: :user

      get notifications_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("通知")
      expect(response.body).to include(other_user.username)
    end

    it "未ログイン時はログイン画面へ遷移する" do
      get notifications_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /notifications/:id/read" do
    it "通知を既読にできる" do
      user = create(:user)
      other_user = create(:user)
      notification = create(:notification, recipient: user, actor: other_user, read_at: nil)
      sign_in user, scope: :user

      patch read_notification_path(notification)

      expect(response).to redirect_to(notifications_path)
      expect(notification.reload.read_at).to be_present
    end
  end

  describe "PATCH /notifications/read_all" do
    it "自分の未読通知を一括既読にできる" do
      user = create(:user)
      other_user = create(:user)
      create_list(:notification, 2, recipient: user, actor: other_user, read_at: nil)
      sign_in user, scope: :user

      patch read_all_notifications_path

      expect(response).to redirect_to(notifications_path)
      expect(user.received_notifications.unread.count).to eq(0)
    end
  end
end
