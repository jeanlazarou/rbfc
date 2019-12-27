require "set"
require "ostruct"

module RBFC

  module BytecodeCompiler

    extend BytecodeCompiler
    
    def self.initial_state bytecode, instructions_to_code
      state = OpenStruct.new

      state.index = 0
      state.values = []
      state.jumps = OpenStruct.new({jump_forward: Set.new, jump_backward: Set.new})
      state.previous = :init
      state.code = instructions_to_code[:init]
      state.instructions_to_code = instructions_to_code

      bytecode.reduce(state) { |state, instruction|
        BytecodeCompiler.gather_values(state, instruction)
      }
    end

    def self.gather_values(state, instruction)
      state.values.push(instruction) if hasValue?(state.previous)
      state.jumps[state.previous].add(instruction) if jump?(state.previous)

      state.previous = instruction

      state
    end

    def self.jump?(instruction)
      instruction == :jump_forward || instruction == :jump_backward
    end

    def self.hasValue?(instruction)
      [
        :add,
        :sub,
        :move_up,
        :move_down,
        :set_value
      ].include?(instruction)
    end

    def self.generate_jit_code(state, instruction)
      if instruction == :jump_forward
        state.code << "loop do"
      end

      if (state.jumps.jump_backward.include?(state.index))
        state.code << "loop do"
      end

      state.code << to_code(state, instruction)

      if instruction == :jump_backward
        state.code << "end"
      end

      if (state.jumps.jump_forward.include?(state.index + 1))
        state.code << "end"
      end

      state.index += 1

      state
    end

    def self.to_code(state, instruction)
      x = state.instructions_to_code[instruction]

      x.respond_to?(:call) ? x.call(state.values.shift) : x
    end
    
  end
end
