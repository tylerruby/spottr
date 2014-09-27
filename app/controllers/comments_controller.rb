class CommentsController < ApplicationController
  before_action :set_commentable
  before_action :set_comment, only: [:up_vote]
  before_action :set_time_back, only: [:up_vote]

  def create
    @comment = @commentable.comments.create(comment_params)
    redirect_to @commentable
  end

  def up_vote
    @comment.liked_by current_user

    render json: {
      votes_count: Comment.
        where(id: @comment.id).with_vote_counts(@time_back).
        first.votes_count
    }
  end

  protected

  def comment_params
    (params.require(:comment).permit(:comment)).merge(user: current_user)
  end

  def set_comment
    @comment = @commentable.comments.find(params[:id])
  end

  def set_commentable
    @commentable = Place.find(params[:place_id])
  end
end
