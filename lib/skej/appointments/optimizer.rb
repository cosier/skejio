module Skej
  module Appointments
    class Optimizer


      def initialize(opts = {})
        @optimizers = []
        @session = opts[:session]
      end

      def optimize(time_blocks, target_modules = :all)
        @target_modules = target_modules

        # Add the GeneralSelector Optimizer to the pipeline, if we can
        @optimizers << o(:provider_priority) if can_use(:provider_priority)
        @optimizers << o(:average_spread)    if can_use(:average_spread)
        @optimizers << o(:general_selector)  if can_use(:general_selector)

        process_optimizations(time_blocks)
      end

      private

      # Optimizer factory builder
      def o(mod)
        namespace = "skej/appointments/optimizations/#{mod.to_s.underscore}"
        namespace.classify.constantize
      end

      def process_optimizations(time_blocks)
        blocks = time_blocks || []
        @optimizers.map do |klass|
          blocks = klass.new(session).process(blocks)
        end

        return blocks
      end

      # Returns true if the target_modules == :all, or contains the module_name
      # in the collection.
      def can_use(module_name)
        target_is_all? or target_includes? module_name
      end

      def session
        @session
      end

      def target_is_all?
        (@target_modules.kind_of? Symbol and @target_modules == :all)
      end

      def target_includes?(module_name)
        (@target_modules.kind_of? Array and @target_modules.include? module_name)
      end

    end
  end
end
