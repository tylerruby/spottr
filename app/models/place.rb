class Place < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state
      obj.country = geo.country
      obj.address = geo.address
    end
  end
  after_validation :reverse_geocode  # auto-fetch address

  belongs_to :user

  validates_presence_of :user_id

  scope :with_vote_counts, ->(time_back) {
    joins(<<-EOQ
      LEFT OUTER JOIN votes
      ON votes.votable_id = places.id
      AND votes.votable_type = 'Place'
      EOQ
    )
    .where('votes.created_at > ?', Time.now - time_back)
    .group('places.id')
    .select('places.*, COUNT(votes.id) as votes_count')
    .order('votes_count DESC')
  }

  acts_as_votable
  has_many :votes, class_name: "ActsAsVotable::Vote", as: :votable

end
