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
  
  def transition_next!
   transition_to! next_state_by_priority 
  end

  # Delegate to the class method
  def log(*args)
    self.class.log(*args)
  end

  # Engage the next state, or retry the current state upon transition failure
  def process_state!
    state = @object.current_state.to_sym
    state_priority = @@PRIORITY_BY_STATE[state] || 0
    target = @@STATES_BY_PRIORITY[ state_priority + 1 ]

    transition_to target
  end

  private

  def current_state_priority
    current_priority = @@PRIORITY_BY_STATE[@object.current_state.to_sym]
    raise "Priority not matched for: #{@object.current_state}" unless current_priority
    current_priority
  end

  def next_state_by_priority
    state = @@STATES_BY_PRIORITY[current_state_priority + 1]
    raise "Next State not matched for: #{current_state_priority} / #{@object.current_state}" unless state
    state
  end

end
