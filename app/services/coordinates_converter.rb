class CoordinatesConverter

  attr_accessor :coordinates, :latitude, :longitude

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def latitude
    coordinates.split(',')[0]
  end

  def longitude
    coordinates.split(',')[1]
  end
end
