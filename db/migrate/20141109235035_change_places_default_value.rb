class ChangePlacesDefaultValue < ActiveRecord::Migration
  def change
  	change_column :places, :price_range, :string, index: true, default: "Under 8"
  end
end