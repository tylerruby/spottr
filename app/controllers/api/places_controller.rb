class Api::PlacesController < ApplicationController
  respond_to :json

  def index
    limit = params[:limit] || 20

    query = <<-EOQ
      latitude > ? AND latitude <= ? AND
      longitude > ? AND longitude < ?
    EOQ

    @places = Place.where(query,
      params[:swlat], params[:nelat],
      params[:swlng], params[:nelng]
    )
    total_places_count = @places.count

    @places = @places
      .order(:cached_votes_up => :desc).limit(limit.to_i)

    render json: {
      places: @places,
      total: total_places_count
    }
  end

  def up_vote
    @place = Place.find(params[:id])
    @place.liked_by(current_user)

    render json: {
      votes_count: @place.votes_count
    }
  end
end
