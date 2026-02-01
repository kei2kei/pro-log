require "rails_helper"
require "ostruct"

RSpec.describe User, type: :model do
  describe "User#バリデーションチェック" do
    it "正常系の確認" do
      expect(build(:user)).to be_valid
    end

    it "ユーザーネームの必須エラー確認" do
      user = build(:user, username: nil)
      expect(user).not_to be_valid
    end

    it "ユーザーネームの重複エラー確認" do
      create(:user, username: "TestUser")
      user = build(:user, username: "testuser")
      expect(user).not_to be_valid
    end

    it "パスワード大文字&数字必須エラー確認" do
      user = build(:user, password: "password1", password_confirmation: "password1")
      expect(user).not_to be_valid
    end

    it "パスワード8文字以上のチェックエラー確認" do
      user = build(:user, password: "Pass1", password_confirmation: "Pass1")
      expect(user).not_to be_valid
    end

    it "Omniauthの媒体単位でのuidの一意性エラー確認" do
      create(:user, provider: "google_oauth2", uid: "abc123")
      user = build(:user, provider: "google_oauth2", uid: "abc123")
      expect(user).not_to be_valid
    end
  end

  describe "User#ステータスの確認" do
    it "退会時のステータスインアクティブ化の確認" do
      user = create(:user, deleted_at: Time.current)
      expect(user.active_for_authentication?).to be(false)
      expect(user.inactive_message).to eq(:deleted_account)
    end
  end

  describe "User#Omniauth系確認" do
    it "重複ユーザーがいない場合の新ユーザー作成確認" do
      auth = OpenStruct.new(
        provider: "google_oauth2",
        uid: "uid-123",
        info: OpenStruct.new(name: "Alice", email: "alice@example.com")
      )

      user = User.from_omniauth(auth)

      expect(user).to be_persisted
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("uid-123")
      expect(user.email).to eq("alice@example.com")
    end

    it "User#既にユーザーいる場合同一ユーザーの検知を確認" do
      existing = create(:user, provider: "google_oauth2", uid: "uid-456")
      auth = OpenStruct.new(
        provider: "google_oauth2",
        uid: "uid-456",
        info: OpenStruct.new(name: "Bob", email: "bob@example.com")
      )

      user = User.from_omniauth(auth)

      expect(user.id).to eq(existing.id)
    end
  end

  describe "User#ユーザー名重複時テスト" do
    it "Omniauthでの作成時ユーザー名が重複していた場合の自動命名確認" do
      create(:user, username: "alice")
      auth = OpenStruct.new(
        info: OpenStruct.new(name: "alice", email: "alice@example.com")
      )

      username = User.build_unique_username(auth)

      expect(username).to start_with("alice_")
    end
  end
end
