class AddPriceRangeToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :price_range, :string, index: true, default: "Under 7"
  end
end