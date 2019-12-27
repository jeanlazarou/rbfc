require 'minitest/autorun'
require 'minitest/unit'
require 'stringio'

require 'rbfc/compiler'
require 'rbfc/tokenizer'

SAMPLE =<<BF
[ A program that outputs everything it reads from the input (file) ]

        current cell is 0 (default initial value)
,       read one character (into cell value)
        (if file is empty current value is unchanged)

[       begin of loop stop if current cell is 0
  .     print cell value
  [-]   decrement loop until value is 0
  ,     read next character if EOF leave 0 (unchanged)
]
BF

module RBFC

  class CompiledCodeMappingTests < Minitest::Test

    def test_instruction_line_mapping
      assert_equal [3, 0], compiled_code.mapping(4)
    end

    def test_instruction_column_mapping
      assert_equal [7, 2], compiled_code.mapping(7)
    end

    def test_no_mapping_for_internal_data

      assert_nil compiled_code.mapping(1)
      assert_nil compiled_code.mapping(3)

    end

    def test_several_instructions_by_line

      assert_equal [8, 2], compiled_code.mapping(8)
      assert_equal [8, 3], compiled_code.mapping(10)
      assert_equal [8, 4], compiled_code.mapping(11)

    end

    def compiled_code

      return @compiled_code if @compiled_code

      tokenizer = Tokenizer.new(StringIO.new(SAMPLE))

      @compiled_code = Compiler.new.compile(tokenizer)

    end

  end

end
