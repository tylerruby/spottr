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

  acts_as_votable

  def votes_count
    votes_for.size
  end

  def as_json(options)
    super(options.merge(methods: [:votes_count]))
  end
end
