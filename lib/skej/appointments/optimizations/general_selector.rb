module Skej
  module Appointments
    module Optimizations
      class GeneralSelector < BaseOptimizer
        def process(input)
          # Invalid input guard
          return input if input.nil? or input.empty?

          if input.count >= 3
            input[1..3]
          else
            input
          end
        end
      end
    end
  end
end
