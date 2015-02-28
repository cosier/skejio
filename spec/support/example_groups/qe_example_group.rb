require_relative './base_example_group'
require_relative './qe_engine_group_mixin'

module QEExampleGroup
  extend ::BaseExampleGroup

  RSpec.configure do |config|
    config.include self
    #config.include Devise::TestHelpers
    config.include Capybara::DSL
    config.include Capybara::RSpecMatchers
  end

  include ::QEEngineGroupMixin
end
