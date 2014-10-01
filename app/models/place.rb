class Place < ActiveRecord::Base
  include Concerns::Votable

  acts_as_commentable

  CUISINE_TYPES = ['mexican', 'american', 'italian', 'asian', 'seafood', 'other']

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
  has_many :menu_items

  validates_presence_of :user_id
  validates_inclusion_of :cuisine_type, in: CUISINE_TYPES
end
