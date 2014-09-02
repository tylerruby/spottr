module PlacesHelper

  def has_coordinates?
    session[:coordinates].present?
  end
end
