module RBFC

  class Slice

    def initialize array, from, to

      raise ArgumentError, "from (#{from}) must be positive" if from < 0
      raise ArgumentError, "from (#{from}) must be lower than to (#{to})" if from > to

      raise ArgumentError, "to (#{to}) is out of bounds" if to >= array.size

      @array = array
      @from, @to = from, to

    end

    def [] i
      @from + i > @to ? nil : @array[@from + i]
    end

    def size
      @to - @from + 1
    end

    def empty?
      @array.empty?
    end

  end

end
