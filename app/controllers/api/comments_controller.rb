class Api::CommentsController < ApplicationController
  respond_to :json

  before_action :set_place
  before_action :set_comment, only: [:up_vote]
  before_action :set_time_back, only: [:index, :up_vote]
  before_action :set_limit, only: [:index]

  def index
    @comments = @place.comments
    total_comments_count = @comments.count

    render json: {
      comments: process_votables(@comments),
      total: total_comments_count
    }
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

  def set_place
    @place = Place.find(params[:place_id])
  end

  def set_comment
    @comment = @place.comments.find(params[:id])
  end
end
