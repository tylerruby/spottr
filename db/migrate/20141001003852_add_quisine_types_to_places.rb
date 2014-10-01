class AddQuisineTypesToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :quisine_type, :string, index: true
  end
end
