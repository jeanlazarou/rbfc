require 'rbfc/runtime'
require 'rbfc/debugger'

module RBFC

  class VirtualMachine

    def initialize code, input = $stdin, output = $stdout
      @code = code
      @input, @output = input, output
    end

    def run debugger = nil

      runtime = Runtime.new

      debugger.runtime = runtime if debugger

      instruction_pointer = 0

      loop do

        instruction = @code[instruction_pointer]

        break unless instruction

        case instruction
        when :output
          @output.putc runtime.get_value

        when :input
          x = @input.getbyte
          runtime.set_value x if x

        when :jump_forward
          if runtime.get_value == 0
            instruction_pointer = @code[instruction_pointer + 1]
          else
            instruction_pointer += 2
          end

          next

        when :jump_backward
          if runtime.get_value == 0
            instruction_pointer += 2
          else
            instruction_pointer = @code[instruction_pointer + 1]
          end

          next

        when :debug
          line = "----------------------------------------------------------"

          puts
          puts line

          Debugger.dump runtime.data, 0, runtime.size

          puts
          puts "Pointer at #{runtime.pointer}"
          puts line

        when :add
          runtime.inc_value @code[instruction_pointer + 1]
          instruction_pointer += 1

        when :sub
          runtime.dec_value @code[instruction_pointer + 1]
          instruction_pointer += 1

        when :move_up
          runtime.inc_pointer @code[instruction_pointer + 1]
          instruction_pointer += 1

        when :move_down
          runtime.dec_pointer @code[instruction_pointer + 1]
          instruction_pointer += 1

        else
          runtime.send instruction

        end

        instruction_pointer += 1

      end

    end

  end

end
