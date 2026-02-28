require "rails_helper"

RSpec.describe "Follows", type: :request do
  def turbo_headers
    { "ACCEPT" => "text/vnd.turbo-stream.html" }
  end

  describe "POST /follows" do
    it "フォローできる" do
      user = create(:user)
      other_user = create(:user)
      sign_in user, scope: :user

      expect {
        post follows_path, params: { followed_id: other_user.id }
      }.to change(Follow, :count).by(1)

      follow = Follow.last
      expect(follow.follower_id).to eq(user.id)
      expect(follow.followed_id).to eq(other_user.id)
      expect(response).to redirect_to(root_path)
    end

    it "turbo_stream でフォローできる" do
      user = create(:user)
      other_user = create(:user)
      sign_in user, scope: :user

      post follows_path, params: { followed_id: other_user.id }, headers: turbo_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("follow_user_#{other_user.id}")
    end

    it "自分自身はフォローできない" do
      user = create(:user)
      sign_in user, scope: :user

      expect {
        post follows_path, params: { followed_id: user.id }, headers: turbo_headers
      }.not_to change(Follow, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "未ログイン時はフォローできない" do
      other_user = create(:user)

      expect {
        post follows_path, params: { followed_id: other_user.id }
      }.not_to change(Follow, :count)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "フォロー通知を作成できる" do
      user = create(:user)
      other_user = create(:user)
      sign_in user, scope: :user

      expect {
        post follows_path, params: { followed_id: other_user.id }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.recipient_id).to eq(other_user.id)
      expect(notification.actor_id).to eq(user.id)
      expect(notification.notifiable).to be_a(Follow)
    end

    it "重複フォロー時は通知を重複作成しない" do
      user = create(:user)
      other_user = create(:user)
      create(:follow, follower: user, followed: other_user)
      sign_in user, scope: :user

      expect {
        post follows_path, params: { followed_id: other_user.id }
      }.not_to change(Notification, :count)
    end
  end

  describe "DELETE /follows/:id" do
    it "フォロー解除できる" do
      user = create(:user)
      other_user = create(:user)
      follow = create(:follow, follower: user, followed: other_user)
      sign_in user, scope: :user

      expect {
        delete follow_path(follow)
      }.to change(Follow, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end

    it "未ログイン時はフォロー解除できない" do
      follow = create(:follow)

      expect {
        delete follow_path(follow)
      }.not_to change(Follow, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
