class AddStateToPlace < ActiveRecord::Migration
  def change
    add_column :places, :state, :string
  end
end
