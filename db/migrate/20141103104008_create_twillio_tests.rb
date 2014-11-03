class CreateTwillioTests < ActiveRecord::Migration
  def change
    create_table :twillio_tests do |t|
      t.string :to_number
      t.text :body

      t.timestamps
    end
  end
end
