module RBFC

  class BytecodeVerifier

    def verify! bytecode

      forward_indexes = []
      backward_indexes = []

      bytecode.each_with_index do |code, i|

        unless BYTECODES.include?(code) || code.is_a?(Numeric)
          raise "Invalid bytecode (index #{i}): #{code}"
        end

        if BYTECODES[code] == :has_arg && !bytecode[i + 1].is_a?(Numeric)
          raise "Invalid bytecode sequence, argument missing (index #{i})"
        end

        if code.is_a?(Numeric) && BYTECODES[bytecode[i - 1]] != :has_arg
          raise "Invalid bytecode sequence, instruction missing (index #{i})"
        end

        if [:jump_forward, :jump_backward].include?(code)

          goto_index = bytecode[i + 1]

          if goto_index < 0 || goto_index > bytecode.size
            raise "Invalid jump index (index #{i + 1})"
          end

          if code == :jump_backward

            if !bytecode[goto_index - 1].is_a?(Numeric) ||
                bytecode[goto_index - 2] != :jump_forward
              raise "Invalid jump index (index #{i + 1})"
            end

            at, expected = forward_indexes.pop
            raise "Invalid jump index (index #{at})" if i + 2 != expected
            raise "Invalid jump index (index #{i + 1})" if goto_index != backward_indexes.pop

          else

            if !bytecode[goto_index - 1].is_a?(Numeric) ||
                bytecode[goto_index - 2] != :jump_backward
              raise "Invalid jump index (index #{i + 1})"
            end

            backward_indexes << i + 2
            forward_indexes << [i + 1, goto_index]

          end

        end

      end

    end

    BYTECODES = {
      :inc_value     => nil,
      :dec_value     => nil,
      :inc_pointer   => nil,
      :dec_pointer   => nil,
      :input         => nil,
      :output        => nil,
      :jump_forward  => :has_arg,
      :jump_backward => :has_arg,
      :debug         => nil,
      :add           => :has_arg,
      :sub           => :has_arg,
      :move_up       => :has_arg,
      :move_down     => :has_arg,
    }

  end

end
