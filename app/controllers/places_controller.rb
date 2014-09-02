class PlacesController < ApplicationController

  def index
    if !!session_coordinates
      coordinates = session_coordinates.split(',')
      @lat = coordinates[0]
      @long = coordinates[1]
    end

    @places = Place.all
    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
      marker.lat place.latitude
      marker.lng place.longitude
      marker.infowindow place.title
    end
  end

  def create
    place = Place.new(place_params)
    current_coordinates = session_coordinates.split(',')
    place.latitude = current_coordinates[0]
    place.longitude = current_coordinates[1]
    place.user = current_user

    if place.save
      flash[:notice] = 'Place created'
    else
      flash[:alert] = 'Error creating the place'
    end

    redirect_to root_path
  end

  private

  def place_params
    params.require(:place).permit(:title)
  end
end
