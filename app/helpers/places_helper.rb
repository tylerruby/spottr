module PlacesHelper

  def has_coordinates?
    session[:coordinates].present?
  end

  def current_city
    results = Geocoder.search(session_coordinates).first
    "#{results.city}, #{results.state}"
  end
end
