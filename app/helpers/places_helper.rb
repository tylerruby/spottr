module PlacesHelper

  def has_coordinates?
    session[:coordinates].present?
  end

  def current_city
    return session[:current_city] if session[:current_city].present?

    results = Geocoder.search(session_coordinates).first
    session[:current_city] = "#{results.city}, #{results.state}"
  end
end
