module RBFC

  class CompiledCode < Array

    attr_accessor :source # an array of source code lines

    def initialize tokenizer

      @tokenizer = tokenizer

      @map = {}

    end

    def << instruction

      if instruction.is_a?(Symbol)
        add_mapping self.length, @tokenizer.line - 1, @tokenizer.column - 1
      end

      super

    end

    def add_mapping code_index, line, col
      @map[code_index] = [line, col]
    end

    def mapping code_index
      @map[code_index]
    end

    def line line_number
      @source[line_number]
    end

    def number_of_lines
      @source.size
    end

  end

end
