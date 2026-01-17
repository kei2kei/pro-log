class ContactMailer < ApplicationMailer
  def contact_email(contact_form)
    @contact_form = contact_form

    mail(
      to: "support@pro-log.jp",
      reply_to: @contact_form.email,
      subject: "[Pro-log] #{@contact_form.subject}"
    )
  end
end
