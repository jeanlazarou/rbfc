require "rbfc/bytecode_compiler"

module RBFC

  class JITCompiler

    def compile bytecode
      state = BytecodeCompiler.initial_state(bytecode, instructions_to_code)

      bytecode.reduce(state) do |state, instruction|
        BytecodeCompiler.generate_jit_code(state, instruction)
      end.code.compact.join("\n")
    end

    private
    
    def instructions_to_code
      {
        init: [
          "pointer = 0",
          "data = [0] * 30000"
        ],
        input: [
            "x = input.getbyte",
            "data[pointer] = x % 256 if x"
          ],
        output: [
            "output.putc data[pointer]"
          ],
        jump_forward: [
            "if data[pointer] == 0",
            "  break",
            "end"
          ],
        jump_backward: [
            "if data[pointer] == 0",
            "  break",
            "end"
          ],
        reset: [
            "data[pointer] = 0"
          ],
        inc_value: [
            "data[pointer] = (data[pointer] + 1) % 256"
          ],
        add: ->(n) {[
            "data[pointer] = (data[pointer] + #{n}) % 256"
          ]},
        dec_value: [
            "data[pointer] = (data[pointer] - 1) % 256"
          ],
        sub: ->(n) {[
            "data[pointer] = (data[pointer] - #{n}) % 256"
          ]},
        inc_pointer: [
            "pointer += 1"
          ],
        move_up: ->(n) {[
            "pointer += #{n}"
          ]},
        dec_pointer: [
            "pointer -= 1"
          ],
        move_down: ->(n) {[
            "pointer -= #{n}"
          ]},
        get_value: [
            "data[pointer]"
          ],
        set_value: ->(v) {[
            "data[pointer] = #{v} % 256"
          ]}
      }
    end

  end

end
