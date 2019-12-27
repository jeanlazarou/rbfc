require 'minitest/autorun'
require 'minitest/unit'

require 'stringio'

require 'rbfc/tokenizer'
require 'rbfc/compiler'

module RBFC

  class CompilerTests < Minitest::Test

    def test_empty_code

      compiled = compile("")

      assert_equal [], compiled

    end

    def test_simple_instructions

      expected = [
        :inc_pointer,
        :dec_pointer,
        :inc_value,
        :dec_value,
        :output,
        :input,
      ]

      compiled = compile("><+-.,")

      assert_equal expected, compiled

    end

    def test_loop

      expected = [
        :jump_forward,
        4,
        :jump_backward,
        2,
      ]

      compiled = compile("[]")

      assert_equal 4, compiled.size

      assert_equal expected, compiled

    end

    def test_nested_loop

      compiled = compile("++[>,[[-]]<-->]")

      assert_equal 21, compiled.size

      assert_equal 21, compiled[3]
      assert_equal 15, compiled[7]
      assert_equal 13, compiled[9]
      assert_equal 10, compiled[12]
      assert_equal  8, compiled[14]
      assert_equal  4, compiled[20]

    end

    def test_unmatched_open_bracket

      message = "Error: Missing open bracket in 'test' at line 1:8"

      e = assert_raises CompileError do
        compile("+>,<-->]")
      end

      assert_equal message, e.message

    end

    def test_unmatched_open_bracket_nested

      message = "Error: Missing open bracket in 'test' at line 6:5"

      e = assert_raises CompileError do
        compiled = compile("++    " + "\n" +
                           "[ ,   " + "\n" +
                           "  >,  " + "\n" +
                           "  [-] " + "\n" +
                           "]     " + "\n" +
                           "<-->] " )
      end

      assert_equal message, e.message

    end

    def test_unmtached_closing_bracket

      message = "Error: Missing closing bracket in 'test' at line 1:8"

      e = assert_raises CompileError do
        compile("+>[,<-->")
      end

      assert_equal message, e.message

    end

    def compile code

      tokenizer = Tokenizer.new(StringIO.new(code))
      tokenizer.source_name = 'test'

      Compiler.new.compile(tokenizer)

    end

  end

end
