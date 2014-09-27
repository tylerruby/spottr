class Api::PlacesController < ApplicationController
  respond_to :json

  before_action :set_time_back, only: [:index, :up_vote]
  before_action :set_limit, only: [:index]
  before_action :set_allowed_kinds, only: [:index]

  def index

    query = <<-EOQ
      places.latitude > ? AND places.latitude <= ? AND
      places.longitude > ? AND places.longitude < ? AND
      places.kind IN (?)
    EOQ

    @places = Place
      .where(query,
        params[:swlat], params[:nelat],
        params[:swlng], params[:nelng],
        @allowed_kinds
      )

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


  def set_allowed_kinds
    @allowed_kinds = []
    Place::KINDS.each do |kind|
      @allowed_kinds << kind if params[kind] == "true"
    end
    @allowed_kinds = Place::KINDS if @allowed_kinds.empty?
  end
end
