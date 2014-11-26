class SchedulerSessionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :scheduler_session, inverse_of: :scheduler_session_transitions
end
