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
    ).order(:cached_votes_up => :desc).limit(20)

    render json: {
      places: @places
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
