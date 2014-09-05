class Api::PlacesController < ApplicationController
  respond_to :json

  def index
    @places = Place.all
    render json: @places
  end
end
