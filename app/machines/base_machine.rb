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
      @@STATES_AVAILABLE = states
      
      @@STATES_BY_PRIORITY = {}
      @@PRIORITY_BY_STATE = {}

      @@STATES_AVAILABLE.each_with_index {  |state_name, index| 
        # Create our own reverse look up tables
        @@STATES_BY_PRIORITY[index] = state_name  
        @@PRIORITY_BY_STATE[state_name] = index
        
        # Register the state with statesman
        state state_name, initial: (index == 0 ? true : false) 
      }

      # chain the transition definition creation
      load_linear_transitions
    end

    def load_linear_transitions
      state :retry
      transition from: :retry, to: :retry
      
      @@STATES_AVAILABLE.each_with_index do |state_name, index|
        if next_state = @@STATES_AVAILABLE[index+1]
          transition from: state_name, to: [next_state.to_sym, :retry]
          # Automatically register the retry back->transition
          transition from: state_name, to: :handshake unless state_name.to_sym == :handshake
          transition from: :retry, to: state_name
        end
      end if @@STATES_AVAILABLE
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
      target = allowed_transitions.select { |s| s != :retry }.first
      binding.pry
      transition_to! target
    rescue Statesman::GuardFailedError, Statesman::TransitionFailedError => e
      Rails.logger.error(e)

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
