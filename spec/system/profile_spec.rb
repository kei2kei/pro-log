require "rails_helper"

RSpec.describe "マイページ", type: :system do
  context "ログイン前" do
    it "アクセスできない" do
      visit profile_path

      expect(page).to have_content(I18n.t("devise.views.sessions.new.title"))
    end
  end

  context "ログイン後" do
    let(:user) { create(:user) }

    before do
      sign_in_as(user)
    end

    it "ヘッダーからプロフィール画面へ遷移できる" do
      click_link I18n.t("shared.header.nav.profile")

      expect(page).to have_content(I18n.t("profiles.show.title"))
    end

    it "アイコンクリックでプロフィール画面へ遷移できる" do
      user.avatar.attach(
        io: File.open(Rails.root.join("app/assets/images/shaker.png")),
        filename: "avatar.png",
        content_type: "image/png"
      )

      visit root_path
      find("img[alt='#{I18n.t("shared.header.avatar_alt")}']").click

      expect(page).to have_content(I18n.t("profiles.show.title"))
    end

    it "マイページでブックマーク一覧が見れる" do
      visit profile_path(tab: "bookmarks")
      expect(page).to have_content(I18n.t("profiles.show.empty.bookmarks"))
    end

    it "マイページでいいねした一覧が見れる" do
      visit profile_path(tab: "likes")
      expect(page).to have_content(I18n.t("profiles.show.empty.likes"))
    end

    it "マイページで投稿したレビューが見れる" do
      visit profile_path(tab: "reviews")
      expect(page).to have_content(I18n.t("profiles.show.empty.reviews"))
    end

    describe "プロフィール編集" do
      context "正常系" do
        it "ユーザー名を変更できる" do
          visit profile_path
          click_link I18n.t("profiles.show.edit_profile")

          fill_in I18n.t("profiles.edit.username_label"), with: "updated_user"
          click_button I18n.t("profiles.edit.submit")

          expect(page).to have_content("updated_user")
        end
      end

      context "異常系" do
        it "ユーザー名が空だと更新できない" do
          visit edit_profile_path

          fill_in I18n.t("profiles.edit.username_label"), with: ""
          click_button I18n.t("profiles.edit.submit")

          expect(page).to have_content("入力内容をご確認ください")
        end
      end
    end

    describe "ログイン情報の変更" do
      context "正常系" do
        it "メールアドレスの変更ができる" do
          visit profile_path
          click_link I18n.t("profiles.show.edit_login_info")

          fill_in I18n.t("devise.views.registrations.edit.email_label"), with: "new_email@example.com"
          fill_in I18n.t("devise.views.registrations.edit.current_password_label"), with: "Password1"
          click_button I18n.t("devise.views.registrations.edit.submit")

          expect(page).to have_content(I18n.t("devise.registrations.update_needs_confirmation"))
        end

        it "パスワードの変更ができる" do
          visit edit_user_registration_path

          fill_in I18n.t("devise.views.registrations.edit.password_label"), with: "NewPassword1"
          fill_in I18n.t("devise.views.registrations.edit.password_confirmation_label"), with: "NewPassword1"
          fill_in I18n.t("devise.views.registrations.edit.current_password_label"), with: "Password1"
          click_button I18n.t("devise.views.registrations.edit.submit")

          expect(page).to have_content(I18n.t("devise.registrations.updated"))
        end
      end

      context "異常系" do
        it "メールアドレスの変更に失敗する" do
          create(:user, email: "taken@example.com")
          visit edit_user_registration_path

          fill_in I18n.t("devise.views.registrations.edit.email_label"), with: "taken@example.com"
          fill_in I18n.t("devise.views.registrations.edit.current_password_label"), with: "Password1"
          click_button I18n.t("devise.views.registrations.edit.submit")

          expect(page).to have_content("このメールアドレスは既に登録されています")
        end
      end
    end

    describe "退会" do
      it "退会手続きを行える" do
        visit profile_path

        accept_confirm do
          click_button I18n.t("profiles.show.delete_account")
        end
        expect(page).to have_content("退会手続きを受け付けました。")
      end
    end
  end
end
