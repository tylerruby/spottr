class PagesController < ApplicationController
  def home
  	if !!session[:coordinates]
      coordinates = session[:coordinates].split(',')
      @lat = coordinates[0]
      @long = coordinates[1]
    end
  end
end
