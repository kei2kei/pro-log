require "rails_helper"

RSpec.describe "ReviewLikes", type: :request do
  describe "POST /likes" do
    it "いいねが作成できる" do
      user = create(:user)
      review = create(:review)
      sign_in user, scope: :user

      expect {
        post likes_path, params: { review_id: review.id }
      }.to change(ReviewLike, :count).by(1)

      expect(response).to redirect_to(review_path(review))
    end

    it "自分のレビューにはいいねできない" do
      user = create(:user)
      review = create(:review, user: user)
      sign_in user, scope: :user

      expect {
        post likes_path, params: { review_id: review.id }, headers: { "HTTP_REFERER" => review_path(review) }
      }.not_to change(ReviewLike, :count)
    end

    it "レビュー投稿者にいいね通知を作成する" do
      owner = create(:user)
      user = create(:user)
      review = create(:review, user: owner)
      sign_in user, scope: :user

      expect {
        post likes_path, params: { review_id: review.id }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.recipient_id).to eq(owner.id)
      expect(notification.actor_id).to eq(user.id)
      expect(notification.notifiable).to be_a(ReviewLike)
    end

    it "同じユーザーの再いいね時は通知を重複作成しない" do
      owner = create(:user)
      user = create(:user)
      review = create(:review, user: owner)
      create(:review_like, user: user, review: review)
      sign_in user, scope: :user

      expect {
        post likes_path, params: { review_id: review.id }
      }.not_to change(Notification, :count)
    end

    it "未ログインではいいねを作成できない" do
      review = create(:review)

      expect {
        post likes_path, params: { review_id: review.id }
      }.not_to change(ReviewLike, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "DELETE /likes/:id" do
    it "いいねを解除できる" do
      user = create(:user)
      review = create(:review)
      like = create(:review_like, user: user, review: review)
      sign_in user, scope: :user

      expect {
        delete like_path(like), headers: { "HTTP_REFERER" => review_path(review) }
      }.to change(ReviewLike, :count).by(-1)

      expect(response).to redirect_to(review_path(review))
    end

    it "未ログインではいいねを解除できない" do
      user = create(:user)
      review = create(:review)
      like = create(:review_like, user: user, review: review)

      expect {
        delete like_path(like), headers: { "HTTP_REFERER" => review_path(review) }
      }.not_to change(ReviewLike, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
