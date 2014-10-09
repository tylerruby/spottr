class Place < ActiveRecord::Base
  include Concerns::Votable

  acts_as_commentable

  CUISINE_TYPES = ['mexican', 'american', 'italian', 'asian', 'seafood', 'other']

  has_attached_file :image, :styles => { :thumb => "70x70#", :small => "200x140#", :medium => "501x270#" }
  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/
  validates_presence_of :image

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
  
  validate :uniqueness_of_place

  def as_json(options={})
    json = super(options)
    json["image_url"] = self.image.url(:thumb)
    json
  end

  protected

  def uniqueness_of_place
    if Place.where(latitude: latitude, longitude: longitude).count >= 1 
      errors[:address] << "is already used by another restaraunt"
    end
  end
end
