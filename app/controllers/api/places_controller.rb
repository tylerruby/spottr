class Api::PlacesController < ApplicationController
  respond_to :json

  before_action :set_time_back, only: [:index]
  before_action :set_limit

  def index

    query = <<-EOQ
      places.latitude > ? AND places.latitude <= ? AND
      places.longitude > ? AND places.longitude < ?
    EOQ

    @places = Place
      .where(query,
        params[:swlat], params[:nelat],
        params[:swlng], params[:nelng]
      )

    total_places_count = @places.count

    @places = @places.with_vote_counts(@time_back)
    @places = @places.limit(@limit)

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

  protected

  def set_time_back
    @time_back = case params[:time_mode]
    when "all"
      100.years
    when "year"
      1.year
    when "month"
      1.month
    when "week"
      1.week
    when "day"
      1.day
    else
      1.month
    end
  end

  def set_limit
    @limit = params[:limit] || 20
  end
end
