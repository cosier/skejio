module Skej
  module Ranges
    class RangeWithMath < Range
      include RangeMath

      def self.from_range(range)
        new range.begin, range.end, range.exclude_end?
      end

      def to_range
        Range.new self.begin, self.end, exclude_end?
      end
    end
  end
end
