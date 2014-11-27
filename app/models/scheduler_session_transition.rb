# == Schema Information
#
# Table name: scheduler_session_transitions
#
#  id                   :integer          not null, primary key
#  to_state             :string(255)      not null
#  metadata             :text             default("{}")
#  sort_key             :integer          not null
#  scheduler_session_id :integer          not null
#  created_at           :datetime
#  updated_at           :datetime
#

class SchedulerSessionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition
  has_paper_trail
 
  belongs_to :scheduler_session, inverse_of: :scheduler_session_transitions

  after_create :log_creation

  def log_creation
    SystemLog.fact title: 'scheduler_session_transition', payload: "created -> SchedulerSession:##{id}"
  end

end
