class Api::MenuItemsController < ApplicationController
  respond_to :json

  before_action :set_place, except: [:list]
  before_action :set_menu_item, only: [:up_vote]
  before_action :set_time_back
  before_action :set_limit, only: [:index, :list]

  def index
    @menu_items = @place.menu_items
    total_menu_items_count = @menu_items.count

    render json: {
      menu_items: process_votables(@menu_items),
      total: total_menu_items_count
    }
  end

  def list
    query = <<-EOQ
      places.latitude > ? AND places.latitude <= ? AND
      places.longitude > ? AND places.longitude < ?
    EOQ

    query_params = [
      params[:swlat], params[:nelat],
      params[:swlng], params[:nelng]
    ]

    if params[:cuisine_type] && params[:cuisine_type] != "all"
      query += " AND places.cuisine_type = ?"
      query_params.push(params[:cuisine_type].strip)
    end

    if params[:price_range] && params[:price_range] != "all"
      query += " AND menu_items.price >= ? AND menu_items.price < ?"
      query_params += case params[:price_range]
                      when "Under 7"
                        [0, 7]
                      when "7-12"
                        [7, 12]
                      when "12-20"
                        [12, 20]
                      when "20-30"
                        [20, 30]
                      when "Over 30"
                        [30, 100000]
                      end
    end

    @menu_items = MenuItem.joins(:place).where(query, *query_params)

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
