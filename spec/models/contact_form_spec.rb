require "rails_helper"

RSpec.describe ContactForm, type: :model do
  describe "ContactForm#バリデーションチェック" do
    it "正常系の確認" do
      form = ContactForm.new(
        name: "テスト",
        email: "test@example.com",
        subject: "件名",
        message: "本文"
      )

      expect(form).to be_valid
    end

    it "メール形式が不正な場合は無効になる" do
      form = ContactForm.new(
        name: "テスト",
        email: "invalid-email",
        subject: "件名",
        message: "本文"
      )

      expect(form).not_to be_valid
    end
  end
end
