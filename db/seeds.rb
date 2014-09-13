# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


user = User.where(email: "test@test.com").first ||
  User.create(email: "test@test.com", password: "password")

500.times do |i|
  User.create(email: "test#{i}@test.com", password: "password")
end

# Creating couple of lat longs for testing around Belarus
lat, lng = 30, -90
lat_max, lng_max = 35, -85

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

print "simulating votes"
Place.all.each do |place|
  print '.'
  time = Time.now
  User.all.each do |user|
    time -= 1.day if rand(3) == 0
    place.liked_by(user)
    place.votes.last.update_attributes(created_at: time)
  end
end
