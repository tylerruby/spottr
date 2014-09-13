class AddKindToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :kind, :string, index: true, null: false, default: "food"
  end
end
