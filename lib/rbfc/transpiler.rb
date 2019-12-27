require "rbfc/javascript_code"
require "rbfc/bytecode_compiler"

module RBFC

  class Transpiler
    def transpile js_name, bytecode
      js, mappings = transform_bytecode(js_name, bytecode)
      
      js = js.join("\n").gsub('loop do', 'for (;;) {').gsub('end', '}')
      
      JavascriptCode.new(js_name, js, mappings)
    end

    def transform_bytecode js_name, bytecode
      state = initial_transpile_state(js_name, bytecode)

      bytecode.reduce(state) do |state, instruction|
        source_positon = bytecode.mapping(state.index)

        source_positon = state.mappings.last[-2, 2] unless source_positon
        
        mapping = [state.index, 0, *source_positon]
        
        BytecodeCompiler.generate_jit_code(state, instruction)

        unless state.code == [nil]
          state.mappings << mapping
        
          state.js << state.code.join(" ")
        end
        
        state.code = []

        state
      end

      [state.js, state.mappings]
    end

    def initial_transpile_state js_name, bytecode
      state = BytecodeCompiler.initial_state(bytecode, instructions_to_code)

      state.js = ["//# sourceMappingURL=#{js_name + ".map"}"]
      
      state.js << [state.code.join(" ")]

      state.code = []
      
      state.mappings = [[], []]

      state
    end

    def instructions_to_code
      {
        init: [
          "let x = '';",
          "let pointer = 0;",
          "const data = new Array(30000).fill(0);"
        ],
        input: [
            "x = input.getbyte();",
            "if (x) data[pointer] = x % 256;"
          ],
        output: [
            "output.putc(data[pointer]);"
          ],
        jump_forward: [
            "if (data[pointer] == 0) {",
            "  break;",
            "}"
          ],
        jump_backward: [
            "if (data[pointer] == 0) {",
            "  break;",
            "}"
          ],
        reset: [
            "data[pointer] = 0;"
          ],
        inc_value: [
            "data[pointer] = (data[pointer] + 1) % 256;"
          ],
        add: ->(n) {[
            "data[pointer] = (data[pointer] + #{n}) % 256;"
          ]},
        dec_value: [
            "data[pointer] = (data[pointer] - 1) % 256;"
          ],
        sub: ->(n) {[
            "data[pointer] = (data[pointer] - #{n}) % 256;"
          ]},
        inc_pointer: [
            "pointer += 1;"
          ],
        move_up: ->(n) {[
            "pointer += #{n};"
          ]},
        dec_pointer: [
            "pointer -= 1;"
          ],
        move_down: ->(n) {[
            "pointer -= #{n};"
          ]},
        get_value: [
            "data[pointer];"
          ],
        set_value: ->(v) {[
            "data[pointer] = #{v} % 256;"
          ]}
      }
    end
  end

end
