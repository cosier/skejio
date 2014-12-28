module Skej
  module Appointments
    class Collider

      def initialize(session)
        @colliders = []
        @session = session
      end

      def detect(time_block, target_colliders = :all)
        @target_colliders = target_colliders
        @time_block = time_block

        @colliders << build(:appointment_detector) if can_use(:appointment)
        @colliders << build(:break_detector) if can_use(:break)

        process_colliders || []
      end

      # Returns a collection of any found collisions.
      def process_colliders
        @colliders.map { |klazz| klazz.new(session: @session) }.map { |detector|
          detector.detect(@time_block)
        }.flatten unless @colliders.empty?
      end

      private

      # Optimizer factory builder
      def build(module_name)
        "skej/appointments/detectors/#{module_name.to_s.underscore}".classify.constantize
      end

      def can_use(target_collider)
        (@target_colliders.kind_of? Symbol and @target_colliders == :all) or (@target_collider.kind_of? Array and @target_collider.include? target_collider.to_sym)
      end

    end
  end
end
