class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]

  has_many :places
  has_many :menu_items

  has_attached_file :image,
    styles: {small: "50x50#", medium: "100x100#"},
    :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image,
    :content_type => /\Aimage\/.*\Z/

  validates_presence_of :name

  acts_as_voter

  def first_name
    (name || "").split(" ").first
  end

  def last_name
    (name || "").split(" ").last
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email || random_email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.image = "#{auth.info.image}?type=large"
    end
  end


  protected

  def self.random_email
    last_user_id = User.last.try(:id) || 0
    email = "changeme#{last_user_id + 1}@gmail.com"
  end
end
