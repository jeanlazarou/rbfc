require_relative 'test_helper'

require 'rbfc/virtual_machine'

module RBFC

  class VirtualMachineTests < Minitest::Test

    def test_empty_code

      run_code []

      expected_trace [0]
      expected_output []

    end
    def test_add_and_print

      run_code [
        :output,
        :inc_value,
        :output,
      ]

      expected_output [0, 1]
      expected_trace [0, 1, 2, 3]

    end
    def test_add_and_change_cell

      run_code [
        :inc_pointer,
        :inc_value,
        :output,
        :dec_pointer,
        :output,
      ]

      expected_output [1, 0]
      expected_trace [0, 1, 2, 3, 4, 5]

    end
    def test_loop

      run_code [
        :inc_value,        # 0
        :inc_value,        # 1
        :inc_value,        # 2

        :jump_forward,     # 3
        9,                 # 4
          :output,         # 5
          :dec_value,      # 6
        :jump_backward,    # 7
        3,                 # 8

        :output,           # 9
      ]

      expected_output [3, 2, 1, 0]

      expected_trace [
        0, 1, 2,

        3, 5, 6, 7, 8,
        3, 5, 6, 7, 8,
        3, 5, 6, 7,

        9,
        10]

    end
    def test_input

      run_code [:input, :output], 'A'

      expected_output [65]

      expected_trace [0, 1, 2]

    end
    def test_end_of_input_leaves_current_cell_unchanged

      run_code [:input, :output, :input, :output], 'A'

      expected_output [65, 65]

      expected_trace [0, 1, 2, 3, 4]

    end
    def test_underflow_becomes_255

      run_code [
        :dec_value,
        :output,
      ]

      expected_output [255]
      expected_trace [0, 1, 2]

    end

    def test_overflow_becomes_0

      run_code [
        :dec_value,
        :output,
        :inc_value,
        :output,
      ]

      expected_output [255, 0]
      expected_trace [0, 1, 2, 3, 4]

    end
    def test_add_instruction

      run_code [
        :dec_value,
        :add,
        7,
        :output,
      ]

      expected_output [6]
      expected_trace [0, 1, 2, 3, 4]

    end
    def test_sub_instruction

      run_code [
        :inc_value,
        :sub,
        4,
        :output,
      ]

      expected_output [253]
      expected_trace [0, 1, 2, 3, 4]

    end
    def test_move_instruction

      run_code [
        :inc_value,
        :move_up,
        4,
        :output,
        :move_down,
        4,
        :output,
      ]

      expected_output [0, 1]
      expected_trace [0, 1, 2, 3, 4, 5, 6, 7]

    end

    def test_underflow

      run_code [
        :dec_value,
        :output,
        :dec_value,
        :output,
      ]

      expected_output [255, 254]
      expected_trace [0, 1, 2, 3, 4]

      run_code [
        :sub,
        2,
        :output,
      ]

      expected_output [254]
      expected_trace [0, 1, 2, 3]

    end

    def test_overflow

      run_code [
        :dec_value,
        :dec_value,
        :inc_value,
        :output,
        :inc_value,
        :output,
      ]

      expected_output [255, 0]
      expected_trace [0, 1, 2, 3, 4, 5, 6]

      run_code [
        :dec_value,
        :dec_value,
        :add,
        2,
        :output,
      ]

      expected_output [0]
      expected_trace [0, 1, 2, 3, 4, 5]

    end

    def run_code code, input = ""

      output = StringIO.new
      input = StringIO.new(input)

      code = CodeArray.new(code)

      vm = VirtualMachine.new(code, input, output)

      vm.run

      @trace = code.trace
      @output = output.string

    end

    def expected_trace run_sequence
      assert_equal run_sequence, @trace
    end

    def expected_output output_values

      expected = StringIO.new

      output_values.each {|v| expected.putc v}

      assert_equal expected.string, @output

    end

  end

end
