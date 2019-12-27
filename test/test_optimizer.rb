require_relative 'test_helper'

require 'rbfc/optimizer'

module RBFC

  class OptimizerTests < Minitest::Test

    def test_increments

      @code = [
        :output,
        :inc_value,
        :inc_value,
        :inc_value,
        :inc_value,
        :output,
      ]

      expected_optimization [
        :output,
        :add, 4,
        :output,
      ]

    end

    def test_decrements

      @code = [
        :output,
        :dec_value,
        :dec_value,
        :dec_value,
        :dec_value,
        :output,
      ]

      expected_optimization [
        :output,
        :sub, 4,
        :output,
      ]

    end

    def test_loop_downto_zero

      @code = [
        :inc_value,      # 0
        :jump_forward,   # 1
        6,               # 2
        :dec_value,      # 3
        :jump_backward,  # 4
        1,               # 5
        :output,         # 6
      ]

      expected_optimization [
        :inc_value,
        :reset,
        :output,
      ]

    end

    def test_loop_upto_zero

      @code = [
        :inc_value,       # 0
        :jump_forward,    # 1
        6,                # 2
        :inc_value,       # 3
        :jump_backward,   # 4
        1,                # 5
        :output,          # 6
      ]

      expected_optimization [
        :inc_value,
        :reset,
        :output,
      ]

    end

    def test_pointer_move_up

      @code = [
        :inc_pointer,
        :inc_pointer,
        :inc_pointer,
      ]

      expected_optimization [
        :move_up, 3,
      ]

    end

    def test_pointer_move_down

      @code = [
        :dec_pointer,
        :dec_pointer,
        :dec_pointer,
      ]

      expected_optimization [
        :move_down, 3,
      ]

    end

    def test_no_optimization

      @code = [
        :inc_value,      # 0
        :jump_forward,   # 1
        7,               # 2
        :inc_value,      # 3
        :input,          # 4
        :jump_backward,  # 5
        3,               # 6
        :output,         # 7
      ]

      expected_optimization @code

    end

    def test_optimize_inc_in_loop

      @code = [
        :inc_value,      # 0
        :jump_forward,   # 1
        8,               # 2
        :inc_value,      # 3
        :inc_value,      # 4
        :inc_value,      # 5
        :jump_backward,  # 6
        3,               # 7
        :output,         # 8
      ]

      expected_optimization [
        :inc_value,
        :jump_forward,
        7,
        :add, 3,
        :jump_backward,
        3,
        :output,
      ]

    end

    def test_cat_program

      @code = RBFC::Compiler.new.compile(RBFC::Tokenizer.new(",[.[-],]"))

      expected_optimization [
        :input, :jump_forward, 8,
        :output,
        :reset,
        :input, :jump_backward, 3
      ]

    end

    def expected_optimization expected

      optimizer = Optimizer.new

      optimized = optimizer.optimize(@code)

      assert_equal expected, optimized

    end

  end

end
