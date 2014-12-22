class BaseSession < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  attr_accessor :twiml_sms, :twiml_voice, :twiml

  # This is an abstract parent class to provide basic Session functionality
  self.abstract_class = true

  # expose the state machine more naturally
  delegate :current_state,
    :process_state!,
    :can_transition_to?,
    :transition_to,
    :transition_to!,
    :available_events,
    to: :state_machine


  before_save   :update_meta_store

  class << self

    def load(customer, business)
      sesh   = false

      # Find a session specific to this:
      # Business, Customer and within the last hour.
      query  = {
        customer_id: customer.id,
        business_id: business.id,
        created_at: 24.hour.ago..DateTime.now,
        is_finished: false
      }

      existing = self.order(created_at: :desc).where(query).first

      if existing
        sesh = existing
        SystemLog.fact(title: self.name.underscore, payload: "loaded -> ID:##{sesh.id}")
      else
        sesh = self.create! query
        SystemLog.fact title: self.name.underscore, payload: "created -> ID:##{sesh.id}"
      end

      # seshion is now ready for use!
      sesh
    end

    def fresh(customer, business)
      properties  = { customer_id: customer.id, business_id: business.id }
      create! properties
    end

    def initial_state
      :handshake
    end

    def transition_class
      ::SchedulerSessionTransition
    end

  end

  def display_name
    "#{self.class.name.underscore}/##{id}"
  end

  def store
    # Hit the instance variable cache
    # Hit the Json eta field backing store
    # Instantiate a new fresh hash for the Session
    @store ||= ActiveSupport::HashWithIndifferentAccess.new((self.meta.present? and JSON.parse(self.meta)) || {})

  end

  # Lazy load this logic engine facade
  def logic(device = false, opts = {})
    @logic_cache ||= {}

    # The latest state for this session
    # (using the db as a mutex across multiple procs)
    if self.persisted?
      fresh_state = self.class.find(id).current_state.to_s.dup
    else
      fresh_state = current_state
    end


    if self.respond_to? :apt and apt.present?
      key = "#{fresh_state}_{session.apt.state.current_state}"
    else
      key = fresh_state
    end

    # Build the engine and stash it into the hash cache
    @logic_cache[key.to_sym] ||= logic_engine((device_type and device_type.to_sym) || device || params[:action])

    # New engine every time
    #logic_engine((device_type and device_type.to_sym) || device || params[:action])
  end

    # For the current Business on this Session,
    # we can lookup a *key setting for this Business.
    #
    # All settings are stored as a Setting model, which belongs_to
    # a Business.
    #
    # This provides simple settings lookup, while also caching lookups.
    #
    # Returns instance of Setting
    def setting(key)
      @setting_cache ||= {}
      return @setting_cache[key] if @setting_cache[key].present?

      log "looking up business setting: <strong>#{key}</strong>"
      setting = Setting.business(business).key(key).first
      raise "Unknown Setting key:#{key}" if setting.nil?

      @setting_cache[key] = setting
      setting
    end

  def store!(key, value)
    SystemLog.fact(title: self.class.name.underscore, payload:"saving_session_metadata( <strong>#{key}</strong>, <strong>#{value}</strong> )")
    store[key] = value
    self.save!
  end

  def last_available_state
    prev = transitions.where.not(to_state: 'retry').order(created_at: :desc).first
    (prev and prev.to_state.to_sym) || :handshake
  end

  # If you utilize the customer input to perform a permenanent side effect,
  # then make sure you clear the session input for the next state to behave correctly.
  #
  # As the next state may happen instantaneously, and not between http requests—
  # thus session input must be handled carefully from state to state, as not to get
  # contaminated.
  def clear_session_input!
    log "clearing session input to avoid state contamination"
    self.input.delete :Digits if self.input
    self.input.delete :Body if self.input
    params.delete :Digits if params
    params.delete :Body if params
  end

  def has_initial_date?
    # If we have an initial date from the initial_decoder,
    # then that means we have an initial date :)
    store[:initial_date_decoded].present?
  end

  def state
    state_machine
  end

  def update_meta_store
    self.meta = JSON.generate(store)
  end

  def update_meta_store!
    update_meta_store
    self.save!
  end

  alias_attribute :commit_meta_store!, :update_meta_store!

  def params
    RequestStore.store[:params]
  end

  def input
    params
  end


  def simple_id
    return uuid if uuid.present?

    self.uuid = find_unique_uuid and uuid
    save!

    uuid
  end

  # Automated method and recommended interface for marking the
  # state as complete.
  #
  # Thus allowing the state guards to let you pass.
  def mark_state_complete!
    store[state.to_s] = :complete
  end

  alias_attribute :mark_as_completed!, :mark_state_complete!

  # Handles the retry of a specific transition state.
  #
  # Taking care to unmark the complete status, allowing the target state
  # to be executed again (retried).
  def retry!(t)
    log "Retrying the state: #{t}"
    # Need to UNMARK the target state's :complete marker.
    # Otherwise once the state loads, it will skip itself again—
    # due to the module thinking it's already complete.
    if store[t] and store[t].to_s == "complete"
      store[t] = false
    end

    retry_key = "#{t}_retrying"
    # Also set that we are "retrying", so the logic module can behave accordingly.
    store[retry_key] = true
    store! retry_key, true


    # Ensure the above change is serialized to the database before
    # applying transition logic.
    commit_meta_store!

    transition_to! t
  end


  private

  # A recursive function to find a unique, but random set of digits.
  # The goal is to produce the smallest number possible (min 4 digits).
  #
  # While maintaining uniqueness, and simplicity.
  def find_unique_uuid(i = 0)
    i = i + 1

    # Based on the current iteration,
    # we adjust the randomness factor.
    if i < 5
      num = Random.rand(10..99)
    elsif i < 7
      num = Random.rand(100..999)
    elsif i < 10
      num = Random.rand(1000..99999)
    else
      num = Random.rand(10000..999999)
    end

    # If this is a unique number, return it
    return num if self.class.where(uuid: num.to_s).first.nil?

    # Otherwise continue recursively until we find a match
    return find_unique_uuid(i)
  end

  def session
    self
  end

  # Mini Logic factory
  def logic_engine(device)
    klass = "Skej::StateLogic::#{current_state.classify}".constantize
    engine = klass.new(session: self, device: device)
    engine
  end

  def log(msg)
    SystemLog.fact(title: self.class.name.underscore, payload: msg)
  end

  def prepare_uuid
    simple_id
  end

  # Used for generating a delta diff of the current changes.
  # Typically called by the after_save model callback.
  def log_changes
    if v = versions.last and v.event == "update" and v.changeset.present? and self.changed?
      meta = v.changeset["meta"]
      if meta
        before = JSON.parse(meta.first)
        after  = JSON.parse(meta.last)
        diff = {}

        after.each do |k,v|
          diff[k] = v if before[k] != after[k]
        end

        formatted_json = diff.to_json.gsub(',', ',<br/>').gsub(/^\{/, '').gsub(/\}$/, '').squeeze(' ')
        log "detected session store changes: <br/>\n<pre>#{formatted_json}</pre>" unless formatted_json.empty?

      end
    end
  end
end
