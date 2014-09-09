# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


user = User.where(email: "test@test.com").first ||
  User.create(email: "test@test.com", password: "password")

# Creating couple of lat longs for testing around Belarus
lat, lng = 50, 25
lat_max, lng_max = 55, 30

n = 0
begin
  lat += 0.1 * rand(10)
  begin
    lng += 0.1 * rand(10)
    n += 1
    Place.create!(user: user, latitude: lat,
                 longitude: lng, title: "test #{n}")
  end while lng < lng_max
end while lat < lat_max
