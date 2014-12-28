module Skej
  module Appointments
    module Optimizations
      class AverageSpread < BaseOptimizer
        def process(input)
          # Invalid input guard
          return input if input.nil? or input.empty?

          # If we have more than 3 inputs, slim it down with an
          # even distribution.
          if input.count > 3

          end

          return input
        end
      end
    end
  end
end
