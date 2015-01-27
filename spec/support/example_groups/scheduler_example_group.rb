module SchedulerExampleGroup
  extend ActiveSupport::Concern
  extend RSpec::ExampleGroups

  included do
    let(:business) { 
      create(:business)
    }
  end

  RSpec.configure do |config|
    config.include self,
      :type => :feature,
      :file_path => %r(spec/features/scheduler)
  end

end
