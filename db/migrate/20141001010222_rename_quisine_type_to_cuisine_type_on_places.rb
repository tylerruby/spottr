class RenameQuisineTypeToCuisineTypeOnPlaces < ActiveRecord::Migration
  def change
    rename_column :places, :quisine_type, :cuisine_type
  end
end
