require 'active_support/concern'

module Concerns
  module Votable
    extend ActiveSupport::Concern

    included do
      acts_as_votable

      has_many :votes,
        class_name: "ActsAsVotable::Vote", as: :votable

      scope :with_vote_counts, ->(time_back) {
        class_name = self.to_s
        table_name = class_name.downcase.pluralize
        join_query = <<-EOQ
          LEFT OUTER JOIN votes
          ON votes.votable_id = #{table_name}.id
          AND votes.votable_type = '#{class_name}'
          AND votes.created_at > "#{(DateTime.now - time_back).to_s(:db)}"
        EOQ

        joins(join_query)
          .group("#{table_name}.id")
          .select("#{table_name}.*, COUNT(votes.id) as votes_count")
          .order('votes_count DESC')
      }
    end


    def voted_by?(user)
      votes.where(voter: user).count > 0
    end
  end
end
