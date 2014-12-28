module Skej
  module Appointments
    module Optimizations
      class ProviderPriority < BaseOptimizer
        def process(input)
          # Invalid input guard
          return input if input.nil? or input.empty?

          # TODO: implement
          return input
        end
      end
    end
  end
end
