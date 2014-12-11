class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|

      # Our internal associations
      t.integer :business_id, null: false
      t.integer :service_provider_id, null: false
      t.integer :office_id, null: false
      t.integer :customer_id, null: false
      t.integer :created_by_session_id, null: false

      # Appointment / iCal based model properties
      t.datetime :start
      t.datetime :end

      t.text :organizer
      t.text :description
      t.text :summary
      t.text :attendees
      t.text :location

      # Auditing and administration properties
      t.integer :status
      t.text :notes

      # Start out unconfirmed
      t.boolean :is_confirmed, default: false

      # Start out active
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
