class MenuItemsController < ApplicationController
  before_action :set_place

  def create
    @place.menu_items.create(menu_item_params)
    redirect_to @place
  end

  protected

  def menu_item_params
    params.require(:menu_item).
      permit(:name, :price, :image)
      .merge(user: current_user)
  end

  def set_place
    @place = Place.find(params[:place_id])
  end
end
