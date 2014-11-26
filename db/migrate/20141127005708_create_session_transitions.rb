class CreateSessionTransitions < ActiveRecord::Migration
  def change
    create_table :session_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :session_id, null: false
      t.timestamps
    end

    add_index :session_transitions, :session_id
    add_index :session_transitions, [:sort_key, :session_id], unique: true
  end
end
