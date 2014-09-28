class MenuItem < ActiveRecord::Base
  include Concerns::Votable

  belongs_to :place
  belongs_to :user

  has_attached_file :image, :styles => {
    :medium => "300x300>", :thumb => "100x100>"
  }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/

  def as_json(options={})
    json = super(options)
    json["image_url"] = self.image.url(:thumb)
    json
  end
end
