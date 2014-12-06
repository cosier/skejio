# == Schema Information
#
# Table name: scheduler_sessions
#
#  id          :integer          not null, primary key
#  business_id :integer
#  customer_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  meta        :text
#  device_type :integer
#

class SchedulerSession < BaseSession

  has_paper_trail

  belongs_to :customer
  belongs_to :business

  has_many :scheduler_session_transitions

  has_many :transitions,
    class_name: 'SchedulerSessionTransition',
    foreign_key: 'scheduler_session_id'

  has_many :appointment_selection_states
  has_one  :appointment_selection_state
  alias_attribute :apt, :appointment_selection_state

  #validates_uniqueness_of :customer_id, :scope => :business_id
  after_save :log_changes

  enum device_type: [:voice, :sms]

  def state_machine
    ::SchedulerStateMachine.new(self, transition_class: ::SchedulerSessionTransition)
  end

  def chosen_office
    Office.where(business_id: business_id, id: store[:chosen_office_id]).first
  end

  def chosen_provider
    User.where(business_id: business_id, id: store[:chosen_provider_id]).first
  end

  def chosen_service
    Service.where(business_id: business_id, id: store[:chosen_service_id]).first
  end

  private

  def log_changes
    if v = versions.last and v.event == "update" and v.changeset.present? and self.changed?
      meta = v.changeset["meta"]
      before = JSON.parse(meta.first)
      after  = JSON.parse(meta.last)
      diff = {}

      after.map do |k,v|
        diff[k] = v if before[k] != after[k]
      end

      formatted_json = diff.to_json.gsub(',', ',<br/>').gsub(/^\{/, '').gsub(/\}$/, '')
      log "session changes: <br/>\n<pre>#{formatted_json}</pre>"
    end
  end




end
