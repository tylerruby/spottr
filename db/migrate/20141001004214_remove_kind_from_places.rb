class RemoveKindFromPlaces < ActiveRecord::Migration
  def change
    remove_column :places, :kind, :string
  end
end
