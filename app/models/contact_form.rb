class ContactForm
  include ActiveModel::Model

  attr_accessor :name, :email, :subject, :message, :website

  validates :name, :email, :subject, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def spam?
    website.present?
  end
end
