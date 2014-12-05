class AppointmentSelectionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition


  belongs_to :appointment_selection_state, inverse_of: :appointment_selection_transitions
end
