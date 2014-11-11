class CreateWorkingTimes < ActiveRecord::Migration
  def change
    create_table :working_times do |t|
      t.integer :wday
      t.integer :start_hours
      t.integer :end_hours
      t.belongs_to :place, index: true

      t.timestamps
    end

    add_index :working_times, [:wday, :start_hours, :end_hours]
  end
end
