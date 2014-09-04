class RemoveIpAddressFromPlace < ActiveRecord::Migration
  def change
    remove_column :places, :ip_address, :string
  end
end
