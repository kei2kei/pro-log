require "rails_helper"

RSpec.describe "ReviewComments", type: :request do
  def turbo_headers
    { "ACCEPT" => "text/vnd.turbo-stream.html" }
  end

  describe "POST /reviews/:review_id/comments" do
    it "コメントを作成できる" do
      user = create(:user)
      review = create(:review)
      sign_in user, scope: :user

      expect {
        post review_review_comments_path(review), params: { review_comment: { body: "ナイスレビューです" } }
      }.to change(ReviewComment, :count).by(1)

      expect(response).to redirect_to(review_path(review))
    end

    it "レビュー投稿者にコメント通知を作成する" do
      owner = create(:user)
      user = create(:user)
      review = create(:review, user: owner)
      sign_in user, scope: :user

      expect {
        post review_review_comments_path(review), params: { review_comment: { body: "ナイスレビューです" } }
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.recipient_id).to eq(owner.id)
      expect(notification.actor_id).to eq(user.id)
      expect(notification.notifiable).to be_a(ReviewComment)
    end

    it "メンションされたユーザーにも通知する（重複なし）" do
      owner = create(:user, username: "owner_user")
      user = create(:user, username: "actor_user")
      mentioned = create(:user, username: "mention_user")
      review = create(:review, user: owner)
      sign_in user, scope: :user

      expect {
        post review_review_comments_path(review), params: { review_comment: { body: "@mention_user 参考になりました @owner_user" } }
      }.to change(Notification, :count).by(2)

      recipients = Notification.order(:id).last(2).map(&:recipient_id)
      expect(recipients).to match_array([ owner.id, mentioned.id ])
    end

    it "turbo_stream でコメント作成できる" do
      user = create(:user)
      review = create(:review)
      sign_in user, scope: :user

      post review_review_comments_path(review),
           params: { review_comment: { body: "参考になりました" } },
           headers: turbo_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("comments_review_#{review.id}")
    end

    it "未ログインではコメント作成できない" do
      review = create(:review)

      expect {
        post review_review_comments_path(review), params: { review_comment: { body: "コメント" } }
      }.not_to change(ReviewComment, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "DELETE /reviews/:review_id/comments/:id" do
    it "自分のコメントを削除できる" do
      user = create(:user)
      comment = create(:review_comment, user: user)
      sign_in user, scope: :user

      expect {
        delete review_review_comment_path(comment.review, comment)
      }.to change(ReviewComment, :count).by(-1)

      expect(response).to redirect_to(review_path(comment.review))
    end

    it "他人のコメントは削除できない" do
      user = create(:user)
      other_user = create(:user)
      comment = create(:review_comment, user: other_user)
      sign_in user, scope: :user

      expect {
        delete review_review_comment_path(comment.review, comment), headers: turbo_headers
      }.not_to change(ReviewComment, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
