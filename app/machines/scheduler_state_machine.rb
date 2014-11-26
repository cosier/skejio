class SchedulerStateMachine
  include Statesman::Machine

  state :handshake, initial: true
  state :initial_parse
  state :finished
  state :error

  transition from: :handshake, to: [:initial_parse, :error]

  before_transition :to => :initial_parse do |session, transition|
    binding.pry
    log 'going to initial parsing'
  end
  
  def next_state
    allowed_transitions.first
  end

  def log(msg)
    Rails.logger.info msg
  end

end
