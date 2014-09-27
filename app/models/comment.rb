class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment
  include Concerns::Votable

  belongs_to :commentable, :polymorphic => true
  delegate :email, to: :user, prefix: true

  default_scope -> { order('created_at ASC') }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user

  def as_json(options={})
    json = super(options)
    json["user_email"] = self.user_email
    json
  end
end
