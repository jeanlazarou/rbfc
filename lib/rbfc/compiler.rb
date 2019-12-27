require 'rbfc/compile_error'

require 'rbfc/compiled_code'
module RBFC

  class Compiler

    def compile tokenizer

      code = CompiledCode.new(tokenizer)

      jumps_stack = []

      tokenizer.each_token do |token|

        break if token == :eof

        code << token

        if token == :jump_forward
          jumps_stack.push code.length
          code << -1
        elsif token == :jump_backward
          i = jumps_stack.pop
          error tokenizer, "Missing open bracket" unless i
          code << i + 1
          code[i] = code.length
        end

      end

      error tokenizer, "Missing closing bracket" unless jumps_stack.empty?

      code

    end

    def error tokenizer, message

      line = tokenizer.line
      column = tokenizer.column
      name = tokenizer.source_name

      raise CompileError.new(message, name, line, column)

    end

  end

end
