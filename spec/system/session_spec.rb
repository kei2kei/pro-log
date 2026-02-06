require "rails_helper"

RSpec.describe "ログイン", type: :system do
  let(:user) { create(:user) }

  describe "画面遷移" do
    it "ヘッダーからログイン画面へ遷移できる" do
      visit root_path
      within("header") do
        click_link I18n.t("shared.header.login")
      end

      expect(page).to have_content(I18n.t("devise.views.sessions.new.title"))
    end

    it "トップページのヒーローセクションのログインリンクからログイン画面へ遷移できる" do
      visit root_path
      within("main") do
        click_link I18n.t("pages.home.cta_login")
      end

      expect(page).to have_content(I18n.t("devise.views.sessions.new.title"))
    end

    it "会員登録画面からログイン画面へ遷移できる" do
      visit new_user_registration_path
      within("main") do
        click_link I18n.t("devise.views.registrations.new.signin_link")
      end

      expect(page).to have_content(I18n.t("devise.views.sessions.new.title"))
    end
  end

  describe "ログイン処理" do
    context "正常系" do
      it "ログインできる" do
        sign_in_as(user)

        expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
      end
    end

    context "異常系" do
      it "パスワードが違うとログインできない" do
        visit new_user_session_path
        fill_in I18n.t("devise.views.sessions.new.email_label"), with: user.email
        fill_in I18n.t("devise.views.sessions.new.password_label"), with: "WrongPass1"
        click_button I18n.t("devise.views.sessions.new.submit")

        expect(page).to have_content(I18n.t("devise.failure.invalid", authentication_keys: "メールアドレス"))
      end
    end
  end
end
