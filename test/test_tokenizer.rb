require 'minitest/autorun'
require 'minitest/unit'

require 'stringio'

require 'rbfc/tokenizer'

module RBFC

  class TokenizerTests < Minitest::Test

    def test_all_language_symbols

      tokenizer = Tokenizer.new(StringIO.new("><+-[].,#"))

      enum = tokenizer.enum_for(:each_token)

      assert_equal :inc_pointer, enum.next
      assert_equal :dec_pointer, enum.next
      assert_equal :inc_value, enum.next
      assert_equal :dec_value, enum.next
      assert_equal :jump_forward, enum.next
      assert_equal :jump_backward, enum.next
      assert_equal :output, enum.next
      assert_equal :input, enum.next
      assert_equal :debug, enum.next

      assert_equal :eof, enum.next

    end

    def test_return_eof_at_end_of_input

      tokenizer = Tokenizer.new(StringIO.new)

      enum = tokenizer.enum_for(:each_token)

      assert_equal :eof, enum.next

    end

    def test_eat_other_characters

      tokenizer = Tokenizer.new(StringIO.new("hello"))

      enum = tokenizer.enum_for(:each_token)

      assert_equal :eof, enum.next

    end

    def test_initial_position_info

      tokenizer = Tokenizer.new(StringIO.new("><+-.,[]"))

      assert_equal 1, tokenizer.line
      assert_equal 0, tokenizer.column

    end

    def test_position_info_one_line

      tokenizer = Tokenizer.new(StringIO.new("><+-.,[]"))

      enum = tokenizer.enum_for(:each_token)

      enum.next
      enum.next

      assert_equal 1, tokenizer.line
      assert_equal 2, tokenizer.column

    end

    def test_position_with_linux_eol

      tokenizer = Tokenizer.new(StringIO.new(">\n<\n+-.,[]"))

      enum = tokenizer.enum_for(:each_token)

      enum.next
      enum.next
      enum.next
      enum.next

      assert_equal 3, tokenizer.line
      assert_equal 2, tokenizer.column

    end

    def test_position_with_win_eol

      tokenizer = Tokenizer.new(StringIO.new(">\r\n<\r\n+-.,[]"))

      enum = tokenizer.enum_for(:each_token)

      enum.next
      enum.next
      enum.next
      enum.next

      assert_equal 3, tokenizer.line
      assert_equal 2, tokenizer.column

    end

    def test_position_with_mac_eol

      tokenizer = Tokenizer.new(StringIO.new(">\r<\r+-.,[]"))

      enum = tokenizer.enum_for(:each_token)

      enum.next
      enum.next
      enum.next
      enum.next

      assert_equal 3, tokenizer.line
      assert_equal 2, tokenizer.column

    end

    def test_position_past_end_of_file

      tokenizer = Tokenizer.new(StringIO.new(">"))

      enum = tokenizer.enum_for(:each_token)

      enum.next

      assert_equal :eof, enum.next

      assert_equal 1, tokenizer.line
      assert_equal 1, tokenizer.column

    end

    def test_position_with_discarded_characters

      tokenizer = Tokenizer.new(StringIO.new("> abc ++"))

      enum = tokenizer.enum_for(:each_token)

      enum.next
      enum.next

      assert_equal 1, tokenizer.line
      assert_equal 7, tokenizer.column

    end

  end

end
