class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.belongs_to :place, index: true
      t.belongs_to :user, index: true
      t.string :name
      t.decimal :price

      t.timestamps
    end
  end
end
