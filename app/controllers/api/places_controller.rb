class Api::PlacesController < ApplicationController
  respond_to :json

  before_action :set_time_back, only: [:index, :up_vote]
  before_action :set_limit, only: [:index]

  def index

    query = <<-EOQ
      places.latitude > ? AND places.latitude <= ? AND
      places.longitude > ? AND places.longitude < ?
    EOQ

    query_params = [
      params[:swlat], params[:nelat],
      params[:swlng], params[:nelng]
    ]

    if params[:cuisine_type] && params[:cuisine_type] != "all"
      query += " AND places.cuisine_type = ?"
      query_params.push(params[:cuisine_type].strip)
    end

    @places = Place.where(query, *query_params)

    total_places_count = @places.count

    render json: {
      places: process_votables(@places),
      total: total_places_count
    }
  end

  def up_vote
    @place = Place.find(params[:id])
    @place.liked_by(current_user)

    render json: {
      votes_count: Place.
        where(id: @place.id).with_vote_counts(@time_back).
        first.votes_count
    }
  end

  protected

end
