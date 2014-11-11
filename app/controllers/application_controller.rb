class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :session_coordinates

  def session_coordinates
    session[:coordinates]
  end

  before_action :set_place_for_new_form

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

  def process_votables(votables)
    votables = votables.with_vote_counts(@time_back)
    votables = votables.limit(@limit)
    # Preparing the json
    votables.map {|p|
      p.as_json.merge({
        upvoted_by_user: p.voted_by?(current_user)
      })
    }
  end

  def set_limit
    @limit = params[:limit] || 15
  end

  def set_place_for_new_form
    @new_place = Place.new
    @new_place.working_times.build(wday: 1, start_hours: 18, end_hours: 34)
  end
end
