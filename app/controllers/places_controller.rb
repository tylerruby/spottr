class PlacesController < ApplicationController

  before_action :get_current_location, only: :index

  def index
    @places = Place.all
    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
      marker.lat place.latitude
      marker.lng place.longitude
      marker.infowindow view_context.link_to place.title, place
    end
  end

  def show
    @place = Place.find(params[:id])
  end

  def create
    place = Place.new(place_params)
    current_coordinates = CoordinatesConverter.new(session_coordinates)
    place.latitude = current_coordinates.latitude
    place.longitude = current_coordinates.longitude
    place.user = current_user

    if place.save
      flash[:notice] = 'Place created'
    else
      flash[:alert] = 'Error creating the place'
    end

    redirect_to root_path
  end

  def up_vote
    @place = Place.find(params[:id])
    @place.liked_by current_user
    redirect_to :back
  end
  private

  def place_params
    params.require(:place).permit(:title, :kind, :image)
  end

  def get_current_location
    return unless session_coordinates.present?

    coordinates = CoordinatesConverter.new(session_coordinates)
    @lat = coordinates.latitude
    @long = coordinates.longitude
  end
end
