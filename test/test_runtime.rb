require 'minitest/autorun'
require 'minitest/unit'

require 'rbfc/runtime'

module RBFC

  class RuntimeTests < Minitest::Test

    def test_initial_size_is_1

      runtime = Runtime.new

      assert_equal 1, runtime.size

    end

    def test_size_increases

      runtime = Runtime.new

      runtime.inc_pointer
      assert_equal 2, runtime.size

      runtime.inc_pointer
      assert_equal 3, runtime.size

    end

    def test_pointer_moved_back

      runtime = Runtime.new

      runtime.inc_pointer
      runtime.inc_pointer
      runtime.inc_pointer
      runtime.inc_pointer

      runtime.dec_pointer
      runtime.dec_pointer

      assert_equal 5, runtime.size

    end

    def test_set_value_greater_than_255

      runtime = Runtime.new

      runtime.set_value 3000
      assert_equal 184, runtime.get_value

    end

  end

end
