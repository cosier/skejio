require 'devise/test_helpers'

module BaseExampleGroup
  # Module extensions
  extend ::ActiveSupport::Concern
  extend ::RSpec::ExampleGroups

  # Method includes
  include ::Devise::TestHelpers
  include ::Rack::Test::Methods
end
