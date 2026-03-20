require "rails_helper"

RSpec.describe "Reviews", type: :request do
  describe "レビュー作成" do
    it "ログインしていない場合はログイン画面にリダイレクトされる" do
      product = create(:product)
      get new_product_review_path(product)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "正常に作成できる" do
      user = create(:user)
      product = create(:product)
      sign_in user

      params = {
        review: {
          title: "溶けやすくて美味しい",
          comment: "毎朝の習慣にしています。",
          overall_score: 4,
          sweetness: 3,
          richness: 4,
          aftertaste: 3,
          flavor_score: 4,
          solubility: 4,
          foam: 2
        }
      }

      expect {
        post product_reviews_path(product), params: params
      }.to change(Review, :count).by(1)

      expect(response).to redirect_to(review_path(Review.last))
    end

    it "フォロワーにレビュー投稿通知を作成する" do
      user = create(:user)
      follower1 = create(:user)
      follower2 = create(:user)
      other_user = create(:user)
      product = create(:product)
      create(:follow, follower: follower1, followed: user)
      create(:follow, follower: follower2, followed: user)
      sign_in user

      params = {
        review: {
          title: "溶けやすくて美味しい",
          comment: "毎朝の習慣にしています。",
          overall_score: 4,
          sweetness: 3,
          richness: 4,
          aftertaste: 3,
          flavor_score: 4,
          solubility: 4,
          foam: 2
        }
      }

      expect {
        post product_reviews_path(product), params: params
      }.to change(Notification, :count).by(2)

      notifications = Notification.order(:id).last(2)
      expect(notifications.map(&:recipient_id)).to match_array([ follower1.id, follower2.id ])
      expect(notifications.map(&:actor_id).uniq).to eq([ user.id ])
      expect(notifications.map(&:notifiable_type).uniq).to eq([ "Review" ])
      expect(notifications.map(&:notifiable_id).uniq).to eq([ Review.last.id ])
      expect(notifications.map(&:recipient_id)).not_to include(other_user.id)
    end

    it "フォロワーがいない場合は通知を作成しない" do
      user = create(:user)
      product = create(:product)
      sign_in user

      params = {
        review: {
          title: "溶けやすくて美味しい",
          comment: "毎朝の習慣にしています。",
          overall_score: 4,
          sweetness: 3,
          richness: 4,
          aftertaste: 3,
          flavor_score: 4,
          solubility: 4,
          foam: 2
        }
      }

      expect {
        post product_reviews_path(product), params: params
      }.not_to change(Notification, :count)
    end

    it "バリデーションエラー時は422を返す" do
      user = create(:user)
      product = create(:product)
      sign_in user

      params = { review: { title: nil } }
      post product_reviews_path(product), params: params

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "未ログインでは作成できない" do
      product = create(:product)
      params = {
        review: {
          title: "未ログイン投稿",
          comment: "投稿されないこと",
          overall_score: 4,
          sweetness: 3,
          richness: 3,
          aftertaste: 3,
          flavor_score: 3,
          solubility: 3,
          foam: 3
        }
      }

      expect {
        post product_reviews_path(product), params: params
      }.not_to change(Review, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "レビュー更新" do
    it "本人のみ更新できる" do
      user = create(:user)
      review = create(:review, user: user)
      sign_in user

      patch review_path(review), params: { review: { title: "更新後" } }

      expect(response).to redirect_to(review_path(review))
      expect(review.reload.title).to eq("更新後")
    end

    it "他人のレビューは更新できない" do
      owner = create(:user)
      other = create(:user)
      review = create(:review, user: owner)
      sign_in other

      patch review_path(review), params: { review: { title: "更新後" } }

      expect(response).to redirect_to(review_path(review))
      expect(review.reload.title).not_to eq("更新後")
    end

    it "未ログインでは更新できない" do
      review = create(:review, title: "更新前")

      patch review_path(review), params: { review: { title: "未ログイン更新" } }

      expect(response).to redirect_to(new_user_session_path)
      expect(review.reload.title).to eq("更新前")
    end
  end

  describe "レビュー削除" do
    it "本人のみ削除できる" do
      user = create(:user)
      review = create(:review, user: user)
      sign_in user

      expect {
        delete review_path(review)
      }.to change(Review, :count).by(-1)

      expect(response).to redirect_to(product_path(review.product))
    end

    it "他人のレビューは削除できない" do
      owner = create(:user)
      other = create(:user)
      review = create(:review, user: owner)
      sign_in other

      expect {
        delete review_path(review)
      }.not_to change(Review, :count)

      expect(response).to redirect_to(review_path(review))
    end

    it "未ログインでは削除できない" do
      review = create(:review)

      expect {
        delete review_path(review)
      }.not_to change(Review, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
