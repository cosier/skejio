class ClearingSettings78294823 < ActiveRecord::Migration
  def change
    Setting.destroy_all
  end
end
