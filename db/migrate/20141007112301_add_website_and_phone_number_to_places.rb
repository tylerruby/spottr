class AddWebsiteAndPhoneNumberToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :website, :string
    add_column :places, :phone_number, :string
  end
end
