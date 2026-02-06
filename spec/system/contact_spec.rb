require "rails_helper"

RSpec.describe "お問い合わせ", type: :system do
  it "お問い合わせを送信できる" do
    allow_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(true)

    visit contact_path

    fill_in I18n.t("pages.contact.form_name"), with: "テストユーザー"
    fill_in I18n.t("pages.contact.form_email"), with: "test@example.com"
    fill_in I18n.t("pages.contact.form_subject"), with: "テスト"
    fill_in I18n.t("pages.contact.form_message"), with: "テスト本文です。"

    click_button I18n.t("pages.contact.submit")

    expect(page).to have_content("お問い合わせを受け付けました。")
  end
end
