require_relative './base_example_group'
require_relative './scheduler_group_mixin'
require_relative './qe_engine_group_mixin'
require_relative '../factory_macros'
require 'devise'


module SchedulerExampleGroup
  extend ::BaseExampleGroup

  include ::SchedulerGroupMixin
  include ::QEEngineGroupMixin

  # RSpec ExampleGroup installation
  RSpec.configure do |config|
    config.include self
    #config.include Devise::TestHelpers
    config.include Capybara::DSL
    config.include Capybara::RSpecMatchers

    config.include FactoryMacros
    config.extend FactoryMacros

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:transaction)
    end

    config.around(:each) do |example|
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  end
end
