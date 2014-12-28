class ConsolidatingTimeBlockTimeValues < ActiveRecord::Migration
  def change
    remove_column :time_blocks, :start_hour, :integer
    remove_column :time_blocks, :start_minute, :integer
    remove_column :time_blocks, :end_hour, :integer
    remove_column :time_blocks, :end_minute, :integer

    add_column :time_blocks, :start_time, :datetime
    add_column :time_blocks, :end_time, :datetime
  end
end
