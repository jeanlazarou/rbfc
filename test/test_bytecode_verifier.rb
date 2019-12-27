require 'stringio'

require 'minitest/autorun'
require 'minitest/unit'

require 'rbfc/compiler'
require 'rbfc/tokenizer'
require 'rbfc/bytecode_verifier'

module RBFC

  class BytecodeVerifierTests < Minitest::Test

    def test_accept_all_instructions

      bytecode = compile('+[-]><,.#')

      BytecodeVerifier.new.verify!(bytecode)

    end

    def test_accept_new_instructions

      bytecode = [
        :add,
        4,
        :sub,
        4,
        :move_up,
        4,
        :move_down,
        4,
      ]

      BytecodeVerifier.new.verify!(bytecode)

    end

    def test_invalid_instruction

      bytecode = [
        :should_not_exist,
        :output,
      ]

      message = "Invalid bytecode (index 0): should_not_exist"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_missing_arguments

      [:jump_forward, :jump_backward, :add, :sub, :move_up, :move_down].each do |inst|

        bytecode = [
          inst,
          :output,
        ]

        message = "Invalid bytecode sequence, argument missing (index 0)"

        e = assert_raises RuntimeError do
          BytecodeVerifier.new.verify!(bytecode)
        end

        assert_equal message, e.message

      end

    end

    def test_unexpected_numbers

      bytecode = [
        44,
        :output,
      ]

      message = "Invalid bytecode sequence, instruction missing (index 0)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_unexpected_arguments

      bytecode = [
        :add,
        44,
        17,
        :output,
      ]

      message = "Invalid bytecode sequence, instruction missing (index 2)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_number_after_no_argument_bytecodes

      no_args_bytecodes = [
        :inc_value,
        :dec_value,
        :inc_pointer,
        :dec_pointer,
        :input,
        :output,
        :debug,
      ]

      no_args_bytecodes.each do |inst|

        bytecode = [
          :input,
          inst,
          11,
          :output,
        ]

        message = "Invalid bytecode sequence, instruction missing (index 2)"

        e = assert_raises RuntimeError do
          BytecodeVerifier.new.verify!(bytecode)
        end

        assert_equal message, e.message

      end

    end

    def test_jump_beyond_upper_bounds

      bytecode = [
        :input,          # 0
        :jump_forward,   # 1
        20,              # 2
        :output,         # 3
        :jump_backward,  # 4
        3,               # 5
        :input,          # 6
      ]

      message = "Invalid jump index (index 2)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_negative_jump_index

      bytecode = [
        :input,          # 0
        :jump_forward,   # 1
        6,               # 2
        :output,         # 3
        :jump_backward,  # 4
        -3,              # 5
        :input,          # 6
      ]

      message = "Invalid jump index (index 5)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_invalid_jump_index

      bytecode = [
        :input,          # 0
        :jump_forward,   # 1
        6,               # 2
        :output,         # 3
        :jump_backward,  # 4
        0,               # 5
        :input,          # 6
      ]

      message = "Invalid jump index (index 5)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_mixed_backward_jumps

      bytecode = [
        :input,          #  0
        :jump_forward,   #  1
        10,              #  2
        :jump_forward,   #  3 <---
        8,               #  4     | (should)
        :output,         #  5 <-  |
        :jump_backward,  #  6   | |
        3,               #  7 --  |
        :jump_backward,  #  8     |
        3,               #  9 ----
        :input,          # 10
      ]

      message = "Invalid jump index (index 7)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_mixed_forward_jumps

      bytecode = [
        :input,          #  0
        :jump_forward,   #  1
        8,               #  2 ----
        :jump_forward,   #  3     |
        10,              #  4 --  | (should)
        :output,         #  5   | |
        :jump_backward,  #  6   | |
        5,               #  7   | |
        :jump_backward,  #  8 <-  |
        3,               #  9     |
        :input,          # 10 <---
      ]

      message = "Invalid jump index (index 4)"

      e = assert_raises RuntimeError do
        BytecodeVerifier.new.verify!(bytecode)
      end

      assert_equal message, e.message

    end

    def test_valid_bytecode

      bytecode = [
        :input,          #  0
        :jump_forward,   #  1
        10,              #  2
        :jump_forward,   #  3
        8,               #  4
        :output,         #  5
        :jump_backward,  #  6
        5,               #  7
        :jump_backward,  #  8
        3,               #  9
        :input,          # 10
      ]

      BytecodeVerifier.new.verify!(bytecode)

    end

    def compile code

      tokenizer = Tokenizer.new(StringIO.new(code))
      tokenizer.source_name = 'test'

      Compiler.new.compile(tokenizer)

    end

  end

end
