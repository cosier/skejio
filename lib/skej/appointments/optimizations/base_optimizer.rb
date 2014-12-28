module Skej
  module Appointments
    module Optimizations
      class BaseOptimizer

        def initialize(sess)
          @session = sess
        end

        def process(input)
          input
        end

        private

        def session
          @session
        end

      end
    end
  end
end

