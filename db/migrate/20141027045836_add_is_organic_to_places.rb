class AddIsOrganicToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :is_organic, :boolean, default: false
  end
end
