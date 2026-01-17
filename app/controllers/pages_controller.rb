class PagesController < ApplicationController
  def home
    @q = Product.ransack(params[:q])
  end

  def about; end

  def terms; end

  def privacy; end

  def contact
    @contact_form = ContactForm.new(
      name: current_user&.username,
      email: current_user&.email
    )
  end
end
