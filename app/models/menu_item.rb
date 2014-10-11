class MenuItem < ActiveRecord::Base
  include Concerns::Votable

  belongs_to :place
  belongs_to :user

  has_attached_file :image, :styles => {
    :medium => "300x300#", :thumb => "70x70#"
  }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/

  validates_presence_of :price
  validates :price, inclusion: { in: 0..10000 }

  def as_json(options={})
    json = super(options)
    json["image_url"] = self.image.url(:thumb)
    json
  end
end
