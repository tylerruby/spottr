class Place < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city    = geo.city
    end
  end
  after_validation :reverse_geocode  # auto-fetch address
end
