module PlacesHelper

  def has_coordinates?
    session_coordinates.present?
  end

  def current_city
    return session[:current_city] if session[:current_city].present?

    if has_coordinates?
      results = Geocoder.search(session_coordinates).first
      session[:current_city] = "#{results.city}, #{results.state}"
    else
      'No Current City'
    end
  end
end
