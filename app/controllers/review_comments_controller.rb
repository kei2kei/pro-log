class ReviewCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review
  before_action :set_review_comment, only: :destroy
  before_action :authorize_review_comment!, only: :destroy

  def create
    @review_comment = @review.review_comments.build(review_comment_params.merge(user: current_user))

    if @review_comment.invalid?
      @review_comments = fetch_review_comments
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to review_path(@review), alert: t("reviews.comments.alert.create_failed") }
      end
      return
    end

    ReviewComment.transaction do
      @review_comment.save!
      create_comment_notifications!
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to review_path(@review), notice: t("reviews.comments.notice.created") }
    end
  rescue ActiveRecord::ActiveRecordError
    @review_comments = fetch_review_comments
    @review_comment.errors.add(:base, t("reviews.comments.alert.create_failed"))
    respond_to do |format|
      format.turbo_stream { render :create, status: :unprocessable_entity }
      format.html { redirect_to review_path(@review), alert: t("reviews.comments.alert.create_failed") }
    end
  end

  def destroy
    if @review_comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to review_path(@review), notice: t("reviews.comments.notice.destroyed") }
      end
    else
      @review_comments = fetch_review_comments
      @review_comment = @review.review_comments.build
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :unprocessable_entity }
        format.html { redirect_to review_path(@review), alert: t("reviews.comments.alert.destroy_failed") }
      end
    end
  end

  private

  def set_review
    @review = Review.find(params[:review_id])
  end

  def set_review_comment
    @review_comment = @review.review_comments.find(params[:id])
  end

  def authorize_review_comment!
    return if @review_comment.user_id == current_user.id

    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = t("reviews.comments.alert.forbidden")
        render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash"), status: :forbidden
      end
      format.html { redirect_to review_path(@review), alert: t("reviews.comments.alert.forbidden") }
    end
  end

  def review_comment_params
    params.require(:review_comment).permit(:body)
  end

  def fetch_review_comments
    @review.review_comments.includes(user: { avatar_attachment: :blob }).order(created_at: :desc)
  end

  def create_comment_notifications!
    recipients = [ @review.user ]
    recipients.concat(mentioned_users(@review_comment.body))
    recipients.uniq!
    recipients.reject! { |user| user.id == current_user.id }

    recipients.each do |recipient|
      Notification.create!(
        recipient: recipient,
        actor: current_user,
        notifiable: @review_comment
      )
    end
  end

  def mentioned_users(body)
    usernames = body.to_s.scan(/@([^\s@]+)/u).flatten.map(&:downcase).uniq
    return User.none if usernames.empty?

    User.where("LOWER(username) IN (?)", usernames)
  end
end
