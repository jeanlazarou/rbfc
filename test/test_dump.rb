require 'stringio'
require 'minitest/autorun'
require 'minitest/unit'

require 'rbfc/debugger'

module RBFC

  class DumpTests < Minitest::Test

    def check_dump_is expected, n = @data.size, from = 0

      buffer = StringIO.new

      Debugger.dump @data, from, n, buffer

      assert_equal expected, buffer.string

    end

    def test_empty_data

      @data = []

      expected = "  0 |                                         | \n"

      check_dump_is expected, 0

    end

    def test_limit_dump_to_given_number

      @data = [72, 32, 33]

      expected = "  0 |  72                                     | H\n"

      check_dump_is expected, 1

    end

    def test_invalid_negative_limit

      @data = [72, 32, 33]

      expected = ""

      check_dump_is expected, -1

    end

    def test_invalid_limit_raises_error

      @data = [72, 32, 33]

      assert_raises ArgumentError do
        check_dump_is "", 10
      end

    end

    def test_11_characters

      @data = [72, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100]

      expected = "  0 |  72 101 108 108 111  32 119 111 114 108 | Hello worl\n" +
                 " 10 | 100                                     | d\n"

      check_dump_is expected

    end

    def test_15_characters

      @data = [
         72, 101, 108, 108, 111, 32, 119, 111, 114, 108,
        100,  32,  46,  46,  46
      ]

      expected = "  0 |  72 101 108 108 111  32 119 111 114 108 | Hello worl\n" +
                 " 10 | 100  32  46  46  46                     | d ...\n"

      check_dump_is expected

    end

    def test_many_characters

      @data = [
         72, 101, 108, 108, 111,  32, 119, 111, 114, 108,
        100,  46,  10,  72, 101, 108, 108, 111,  32, 119,
        111, 114, 108, 100,  46,  10,  72, 101, 108, 108,
        111,  32, 119, 111, 114, 108, 100,  46
      ]

      expected = "  0 |  72 101 108 108 111  32 119 111 114 108 | Hello worl\n" +
                 " 10 | 100  46  10  72 101 108 108 111  32 119 | d..Hello w\n" +
                 " 20 | 111 114 108 100  46  10  72 101 108 108 | orld..Hell\n" +
                 " 30 | 111  32 119 111 114 108 100  46         | o world.\n"

      check_dump_is expected

    end

    def test_non_printable_characters

      @data = [72, 1, 8, 0, 11,  32, 9]

      expected = "  0 |  72   1   8   0  11  32   9             | H.... .\n"

      check_dump_is expected

    end

    def test_from_offset

      @data = [72, 1, 8, 0, 11,  32, 9, 77, 66, 99, 112, 121, 112, 67, 108, 108]

      expected = "  4 |  11  32   9  77  66  99 112 121 112  67 | . .MBcpypC\n"

      check_dump_is expected, 10, 4

    end

  end

end
