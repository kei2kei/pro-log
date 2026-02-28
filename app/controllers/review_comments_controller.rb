class ReviewCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review
  before_action :set_review_comment, only: :destroy
  before_action :authorize_review_comment!, only: :destroy

  def create
    @review_comment = @review.review_comments.build(review_comment_params.merge(user: current_user))

    if @review_comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to review_path(@review), notice: "コメントを投稿しました。" }
      end
    else
      @review_comments = fetch_review_comments
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to review_path(@review), alert: "コメントの投稿に失敗しました。" }
      end
    end
  end

  def destroy
    if @review_comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to review_path(@review), notice: "コメントを削除しました。" }
      end
    else
      @review_comments = fetch_review_comments
      @review_comment = @review.review_comments.build
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :unprocessable_entity }
        format.html { redirect_to review_path(@review), alert: "コメントの削除に失敗しました。" }
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
        flash.now[:alert] = "このコメントは削除できません。"
        render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash"), status: :forbidden
      end
      format.html { redirect_to review_path(@review), alert: "このコメントは削除できません。" }
    end
  end

  def review_comment_params
    params.require(:review_comment).permit(:body)
  end

  def fetch_review_comments
    @review.review_comments.includes(user: { avatar_attachment: :blob }).order(created_at: :desc)
  end
end
