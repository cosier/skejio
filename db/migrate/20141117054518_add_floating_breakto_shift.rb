class AddFloatingBreaktoShift < ActiveRecord::Migration
  def change
    add_column :break_shifts, :floating_break, :integer, default: 0
  end
end
