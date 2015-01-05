module Skej
  module Ranges
    class Seq

      attr_reader :ranges

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
          [rng.begin + 10.seconds.. rng.end - 10.seconds, target].flatten.intersection
        end

        matches.select do |m|
          m.kind_of? Range
        end
      end

    end
  end
end
