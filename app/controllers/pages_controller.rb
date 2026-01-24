class PagesController < ApplicationController
  def home
    @q = Product.ransack(params[:q])
    return unless user_signed_in?

    @recommended_products = Recommendations::ProductRecommender.new(current_user).recommend
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

  def create_contact
    @contact_form = ContactForm.new(contact_params)

    if @contact_form.spam?
      redirect_to contact_path, notice: "お問い合わせを受け付けました。"
      return
    end

    unless verify_recaptcha(model: @contact_form)
      render :contact, status: :unprocessable_entity
      return
    end

    if @contact_form.valid?
      ContactMailer.contact_email(@contact_form).deliver_now
      redirect_to contact_path, notice: "お問い合わせを受け付けました。"
    else
      render :contact, status: :unprocessable_entity
    end
  rescue StandardError
    flash.now[:alert] = "送信に失敗しました。時間をおいて再度お試しください。"
    render :contact, status: :unprocessable_entity
  end

  private

  def contact_params
    params.require(:contact_form).permit(:name, :email, :subject, :message, :website)
  end
end
