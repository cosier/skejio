# == Schema Information
#
# Table name: appointment_selection_transitions
#
#  id                             :integer          not null, primary key
#  to_state                       :string(255)      not null
#  metadata                       :text             default("{}")
#  sort_key                       :integer          not null
#  appointment_selection_state_id :integer          not null
#  created_at                     :datetime
#  updated_at                     :datetime
#

class AppointmentSelectionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition


  belongs_to :appointment_selection_state, inverse_of: :appointment_selection_transitions
end
