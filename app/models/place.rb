class Place < ActiveRecord::Base
  include Concerns::Votable

  acts_as_commentable

  CUISINE_TYPES = ['American', 'Asian', 'BBQ', 'Breakfast', 'Burgers', 'Italian', 'Mexican', 'Pizza', 'Seafood',
                   'Bar', 'Deli', 'Bakery', 'Dessert', 'Steakhouse', 'Other']
  PRICE_RANGES = ['Under 8', '8-13', '13-20', '20-30', 'Over 30']

  has_attached_file :image, :styles => { :thumb => "70x70#", :tiny => "150x120#", :small => "200x140#", :medium => "501x270#" }
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

  scope :open, ->(time) {
    dow, hour = WorkingTime.normalized_day_of_week_and_hour(time)

    query = <<-EOQ
      working_times.wday = ? AND
      working_times.start_hours < ? AND
      working_times.end_hours >= ?
    EOQ

    joins(:working_times).
      where(query, dow, hour, hour).
      group("places.id")
  }

  belongs_to :user
  has_many :menu_items

  has_many :working_times
  accepts_nested_attributes_for :working_times, allow_destroy: true

  validates_presence_of :user_id
  validates_inclusion_of :cuisine_type, in: CUISINE_TYPES
  validates_inclusion_of :price_range, in: PRICE_RANGES

  validate :uniqueness_of_place, on: :create

  def as_json(options={})
    json = super(options)
    json["image_url"] = self.image.url(:tiny)
    json["preview_image_url"] = self.image.url(:thumb)
    json
  end

  protected

  def uniqueness_of_place
    if Place.where(latitude: latitude, longitude: longitude).count >= 1 
      errors[:address] << "is already used by another restaraunt"
    end
  end
end
