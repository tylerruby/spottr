class Api::PlacesController < ApplicationController
  respond_to :json

  def index
    query = <<-EOQ
      latitude > ? AND latitude <= ? AND
      longitude > ? AND longitude < ?
    EOQ
    @places = Place.where(query,
      params[:swlat], params[:nelat],
      params[:swlng], params[:nelng]
    )

    render json: {
      places: @places
    }
  end
end
