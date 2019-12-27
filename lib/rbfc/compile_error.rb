module RBFC

  class CompileError < StandardError

    attr_reader :file, :line, :column

    def initialize message, file, line, column

      super message

      @file, @line, @column = file, line, column

    end

    def to_s
      "Error: #{super} in '#{@file}' at line #{@line}:#{@column}"
    end

  end

end

