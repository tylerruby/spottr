class Api::MenuItemsController < ApplicationController
  respond_to :json

  before_action :set_place
  before_action :set_menu_item, only: [:up_vote]
  before_action :set_time_back, only: [:index, :up_vote]
  before_action :set_limit, only: [:index]

  def index
    @menu_items = @place.menu_items
    total_menu_items_count = @menu_items.count

    render json: {
      menu_items: process_votables(@menu_items),
      total: total_menu_items_count
    }
  end

  def up_vote
    @menu_item.liked_by current_user
    render json: {
      votes_count: MenuItem.
        where(id: @menu_item.id).with_vote_counts(@time_back).
        first.votes_count
    }
  end

  protected

  def set_place
    @place = Place.find(params[:place_id])
  end

  def set_menu_item
    @menu_item = @place.menu_items.find(params[:id])
  end
end
