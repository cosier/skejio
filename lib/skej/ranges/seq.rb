module Skej
  module Ranges
    class Seq

      def initialize(*rngs)
        @ranges = []
        rngs.each{|r| self.add r}
      end

      def add(range)
        @ranges << range
        return self
      end

      def &(seq)
        [@ranges, seq.ranges].flatten.intersection
      end

      def intersect_with(target)
        target = target.ranges unless target.kind_of? Range

        matches = ranges.flatten.map do |rng|
          [rng.begin.. rng.end, target].flatten.intersection
        end

        matches.select do |m|
          m.kind_of? Range
        end
      end

      def with(target)
        # Apply intersection to both time_slot_ranges and collision_ranges
        ranges.map { |r| target.intersect_with(r) }.flatten
      end

      def ranges
        @ranges.flatten unless @ranges.nil?
      end

    end
  end
end
