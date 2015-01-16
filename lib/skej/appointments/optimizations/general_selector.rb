module Skej
  module Appointments
    module Optimizations
      class GeneralSelector < BaseOptimizer
        def process(input)
          return input # tmp disable

          # Invalid input guard
          return input if input.nil? or input.empty?

          if input.count >= 3
            input[0..2] # Zero based index
          else
            input
          end
        end
      end
    end
  end
end
