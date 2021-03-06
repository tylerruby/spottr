class MenuItem < ActiveRecord::Base
  include Concerns::Votable

  belongs_to :place
  belongs_to :user

  has_attached_file :image, :styles => {
    :medium => "300x300#", :tiny => "150x120#", :thumb => "70x70#"
  }, :default_url => "/images/menu_items/:style/missing.png"
  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/

  validates_presence_of :price
  validates :price, inclusion: { in: 0..10000 }

  scope :open, ->(time) {
    dow, hour = WorkingTime.normalized_day_of_week_and_hour(time)

    query = <<-EOQ
      working_times.wday = ? AND
      working_times.start_hours < ? AND
      working_times.end_hours >= ?
    EOQ

    joins(:place => :working_times).
      where(query, dow, hour, hour).
      group("menu_items.id")
  }

  def as_json(options={})
    json = super(options)
    json["title"] = self.name
    json["preview_image_url"] = self.image.url(:thumb)
    json["image_url"] = self.image.url(:tiny)
    json["place_title"] = self.place.title
    json["latitude"] = self.place.latitude
    json["longitude"] = self.place.longitude
    json
  end
end
