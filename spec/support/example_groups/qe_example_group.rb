require_relative './base_example_group'

module QEExampleGroup
  extend ::BaseExampleGroup

  RSpec.configure do |config|
    config.include self,
      :type => :request,
      :file_path => %r(spec/requests)
  end

  include ::QEEngineGroupMixin


end
