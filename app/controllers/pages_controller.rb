class PagesController < ApplicationController
  def home
  	if !!session[:coordinates]
      coordinates = session[:coordinates].split(',')
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
end
