require "rails_helper"

RSpec.describe "会員登録", type: :system do
  describe "画面遷移" do
    it "ヘッダーから会員登録画面へ遷移できる" do
      visit root_path
      click_link I18n.t("shared.header.signup")

      expect(page).to have_content(I18n.t("devise.views.registrations.new.title"))
    end

    it "トップページのヒーローセクションの会員登録リンクから会員登録画面へ遷移できる" do
      visit root_path
      click_link I18n.t("pages.home.cta_signup")

      expect(page).to have_content(I18n.t("devise.views.registrations.new.title"))
    end

    it "ログイン画面から会員登録画面へ遷移できる" do
      visit new_user_session_path
      within("main") do
        click_link I18n.t("devise.views.sessions.new.signup_link")
      end

      expect(page).to have_content(I18n.t("devise.views.registrations.new.title"))
    end
  end

  describe "会員登録" do
    context "正常系" do
      it "ユーザーを作成できる" do
        visit new_user_registration_path

        fill_in I18n.t("devise.views.registrations.new.username_label"), with: "NewUser"
        fill_in I18n.t("devise.views.registrations.new.email_label"), with: "new@example.com"
        fill_in I18n.t("devise.views.registrations.new.password_label"), with: "Password1"
        fill_in I18n.t("devise.views.registrations.new.password_confirmation_label"), with: "Password1"

        click_button I18n.t("devise.views.registrations.new.submit")

        expect(page).to have_content(I18n.t("devise.registrations.signed_up_but_unconfirmed"))
      end
    end

    context "異常系" do
      it "入力に不備があると作成できない" do
        create(:user, email: "dup@example.com")

        visit new_user_registration_path
        fill_in I18n.t("devise.views.registrations.new.username_label"), with: ""
        fill_in I18n.t("devise.views.registrations.new.email_label"), with: "dup@example.com"
        fill_in I18n.t("devise.views.registrations.new.password_label"), with: "Password1"
        fill_in I18n.t("devise.views.registrations.new.password_confirmation_label"), with: "Password1"

        click_button I18n.t("devise.views.registrations.new.submit")

        expect(page).to have_content(I18n.t("shared.form_errors.title", count: 2))
      end
    end
  end
end
