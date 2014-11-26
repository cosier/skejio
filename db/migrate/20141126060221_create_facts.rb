class CreateFacts < ActiveRecord::Migration
  def change
    create_table :facts do |t|
      t.integer :system_log_id
      t.string  :title
      t.integer :type
      t.text    :payload
      t.timestamps
    end
  end
end
