module SystemHelpers
  def sign_in_as(user, password: "Password1")
    visit new_user_session_path
    fill_in I18n.t("devise.views.sessions.new.email_label"), with: user.email
    fill_in I18n.t("devise.views.sessions.new.password_label"), with: password
    click_button I18n.t("devise.views.sessions.new.submit")
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
