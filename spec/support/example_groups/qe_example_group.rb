module QEExampleGroup
  extend ActiveSupport::Concern


  RSpec.configure do |config|
    config.include self,
      :type => :feature,
      :example_group => { :file_path => %r(spec/features/query_engine) }
  end

end
