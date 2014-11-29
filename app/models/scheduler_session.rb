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

  belongs_to :customer

  #has_paper_trail
  has_many :scheduler_session_transitions

  has_many :transitions,
    class_name: 'SchedulerSessionTransition',
    foreign_key: 'scheduler_session_id'

  validates_uniqueness_of :customer_id, :scope => :business_id

  def state_machine
    ::SchedulerStateMachine.new(self, transition_class: ::SchedulerSessionTransition)
  end


end
