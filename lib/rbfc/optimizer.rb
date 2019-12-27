module RBFC

  class Optimizer

    def optimize code

      code = code.reverse

      optimized = []

      loop do

        instruction = code.pop

        break if instruction.nil?

        case instruction
        when :inc_value, :dec_value,
             :inc_pointer, :dec_pointer

          count = count_repetition(code, instruction)

          if count == 1
            optimized << instruction
          else
            optimized << advanced(instruction)
            optimized << count
          end

        when :jump_forward

          lookahead = code[-3..-2]

          if lookahead == [:jump_backward, :inc_value] ||
             lookahead == [:jump_backward, :dec_value]

             code.pop 4

             optimized << :reset

          else

            optimized << :jump_forward

          end

        else

          optimized << instruction

        end

      end

      reset_jumps optimized

      optimized

    end

    private

    def advanced instruction

      {
        :inc_value => :add,
        :dec_value => :sub,
        :inc_pointer => :move_up,
        :dec_pointer => :move_down
      }
      .fetch(instruction)

    end

    def count_repetition code, instruction

      count = 1

      while instruction == code.last

        count += 1

        code.pop

      end

      count

    end

    def reset_jumps code

      jumps_stack = []

      code.each_with_index do |instruction, i|

        if instruction == :jump_forward
          jumps_stack.push i
        elsif instruction == :jump_backward
          match_jump = jumps_stack.pop
          code[match_jump + 1] = i + 2
          code[i + 1] = match_jump + 2
        end

      end

    end

  end

end
