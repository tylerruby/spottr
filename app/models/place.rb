class Place < ActiveRecord::Base
  KINDS = ["food", "club", "bar"]

  acts_as_commentable

  has_attached_file :image, :styles => { :thumb => "200x140#", :medium => "501x270#" }
  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/

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
  validates :kind, inclusion: {in: KINDS}

  def voted_by?(user)
    votes.where(voter: user).count > 0
  end

  scope :with_vote_counts, ->(time_back) {
    join_query = <<-EOQ
      LEFT OUTER JOIN votes
      ON votes.votable_id = places.id
      AND votes.votable_type = 'Place'
      AND votes.created_at > "#{(DateTime.now - time_back).to_s(:db)}"
    EOQ

    joins(join_query)
      .group('places.id')
      .select('places.*, COUNT(votes.id) as votes_count')
      .order('votes_count DESC')
  }

  acts_as_votable
  has_many :votes, class_name: "ActsAsVotable::Vote", as: :votable

end
