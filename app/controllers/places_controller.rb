class PlacesController < ApplicationController

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
