class RemoveIpAddressFromPlace < ActiveRecord::Migration
  def change
    remove_column :placesgd, :ip_address, :string
  end
end
