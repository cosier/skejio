class BaseMachine
  include Statesman::Machine

  #################################
  # Class methods for StateMachine
  class << self

    def log(msg)
      SystemLog.fact(title: 'scheduler_state_machine', payload: msg)
      Rails.logger.info "scheduler_state_machine: #{msg}"
    end

    # Define states dynamically
    def linear_states(*states)
      @@available_states = states
      @@available_states.each_with_index {  |state_name, index| 
        state state_name, initial: (index == 0 ? true : false) }
      load_linear_transitions
    end

    def load_linear_transitions
      state :retry
      @@available_states.each_with_index do |state_name, index|
        if next_state = @@available_states[index+1]
          transition from: state_name, to: [next_state.to_sym, :retry]
          # Automatically register the retry back->transition
          transition from: :retry, to: state_name
        end
      end if @@available_states
    end

  end # End class methods
  #################################

  # Engage the next state, or retry the current state upon transition failure
  def process_state!
    begin
      transition_to! allowed_transitions.select { |s| s != :retry }.first
    rescue Statesman::GuardFailedError
      transition_to! :retry
    end
  end


end
