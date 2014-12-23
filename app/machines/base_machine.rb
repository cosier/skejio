class BaseMachine
  include Statesman::Machine

  #################################
  # Class methods for StateMachine
  class << self

    # Utility counter reader
    # for the static guard context blocks
    def counter(key)
      entry = RequestStore.store[key]
      entry = 0 if entry.nil?
      entry = entry.to_i
    end

    # Utility counter incrementer
    # for the static guard context blocks
    def inc!(key)
      entry = RequestStore.store[key]
      entry = 0 if entry.nil?
      RequestStore.store[key] = entry + 1
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
          transition from: state_name, to: state_name
        end
      end if @@STATES_AVAILABLE
    end

    # Log wrapper for this namespace
    def log(msg)
      SystemLog.fact(title: self.name.underscore, payload: msg)
      Rails.logger.info "#{self.name.underscore}: #{msg}"
    end

  end # End class methods
  #################################

  # Global before / after hooks

  # Log every transition attempted
  before_transition do |object, transition|
    log "transitioning from: #{object.current_state}"
  end

  # Log every transition complete
  after_transition do |object, transition|
    key = object.current_state.to_sym
    log "transitioned to: <strong>#{key}</strong>"

    # Run the logic processing
    object.logic.process!
  end

  # Engage the next state, or retry the current state upon transition failure
  def process!
    session.logic.process!
  end

  def transition_next!
    begin
      transition_to! next_state_by_priority
    rescue Statesman::GuardFailedError => e
      log "unable to transition_next! \n#{e.message}"
      #retry_last_available_state
    end
  end

  def retry_last_available_state
    transition_to last_state_by_priority
  end

  # Delegate to the class method
  def log(*args)
    self.class.log(*args)
  end

  def current_state_priority
    current_priority = @@PRIORITY_BY_STATE[@object.current_state.to_sym]

    if current_priority.nil?
      raise "Priority not matched for: #{@object.current_state}"
    end

    current_priority
  end

  def next_state_by_priority
    @@STATES_BY_PRIORITY[current_state_priority + 1] || @@STATES_BY_PRIORITY[1]
  end

  def last_state_by_priority
    if current_state.to_s == "retry"
      state = @@STATES_BY_PRIORITY[@object.last_available_state]
    else
      state = @@STATES_BY_PRIORITY[current_state_priority - 1]
      state || :handshake
    end
  end

  private

  def session
    @object
  end

end
