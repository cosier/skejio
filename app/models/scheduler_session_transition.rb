class SchedulerSessionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition
  has_paper_trail
 
  belongs_to :scheduler_session, inverse_of: :scheduler_session_transitions

  after_create :log_creation

  def log_creation
    SystemLog.fact title: 'scheduler_session_transition', payload: "CREATED:#{self.to_json}"
  end

end
