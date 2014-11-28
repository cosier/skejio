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

      # chain the transition definition creation
      load_linear_transitions
    end

    def load_linear_transitions
      state :retry
      transition from: :retry, to: :retry

      @@available_states.each_with_index do |state_name, index|
        if next_state = @@available_states[index+1]
          transition from: state_name, to: [next_state.to_sym, :retry, :handshake]
          # Automatically register the retry back->transition
          transition from: :retry, to: state_name
        end
      end if @@available_states
    end

  end # End class methods
  #################################

  # Delegate to the class method
  def log(*args)
    self.class.log(*args)
  end

  # Engage the next state, or retry the current state upon transition failure
  def process_state!
    begin
      transition_to! allowed_transitions.select { |s| s != :retry }.first
    rescue
      log 'process_state failure: attempting to transition to :retry'
      if @object.can_transition_to? :retry
        @object.transition_to! :retry
      else
        log 'retry_transition denied: attempting to transition back to :handshake'
        @object.transition_to! :handshake
      end
    end
  end


end
