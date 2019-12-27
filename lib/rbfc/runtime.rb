module RBFC

  class Runtime

    attr_reader :pointer
    attr_reader :data, :size

    def initialize
      @size = 1
      @pointer = 0
      @data = [0] * 30000
    end

    def inc_pointer n = 1
      @pointer += n
      @size = [@size, @pointer + 1].max
    end

    def dec_pointer n = 1
      @pointer -= n
    end

    def inc_value n = 1
      @data[@pointer] = (@data[@pointer] + n) % 256
    end

    def dec_value n = 1
      @data[@pointer] = (@data[@pointer] - n) % 256
    end

    def reset
      @data[@pointer] = 0
    end

    def get_value
      @data[@pointer]
    end

    def set_value v
      @data[@pointer] = v % 256
    end

  end

end
