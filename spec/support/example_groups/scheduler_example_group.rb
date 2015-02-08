require_relative './base_example_group'
require_relative './scheduler_group_mixin'
require_relative './qe_engine_group_mixin'

module SchedulerExampleGroup
  extend ::BaseExampleGroup

  # RSpec ExampleGroup installation
  RSpec.configure do |config|
    config.include self,
      :type => :request,
      :file_path => %r(spec/requests)
  end
  
  include ::SchedulerGroupMixin
  include ::QEEngineGroupMixin
end
