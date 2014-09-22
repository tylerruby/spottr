class CommentsController < ApplicationController
  before_action :set_commentable

  def create
    @comment = @commentable.comments.create(comment_params)
    redirect_to @commentable
  end

  protected

  def comment_params
    (params.require(:comment).permit(:comment)).merge(user: current_user)
  end

  def set_commentable
    @commentable = Place.find(params[:place_id])
  end
end
