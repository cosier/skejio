module BaseExampleGroup
  extend ::ActiveSupport::Concern
  extend ::RSpec::ExampleGroups

  include ::Rack::Test::Methods
end
