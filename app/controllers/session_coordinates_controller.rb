class SessionCoordinatesController < ApplicationController
  def create
    coordinates = "%s,%s" % [params[:latitude], params[:longitude]]
    session[:coordinates] = coordinates
  end
end
