require 'minitest/autorun'
require 'minitest/unit'

require 'rbfc/base64_vlq_coder'

module RBFC

  class VLQTests < Minitest::Test

    def test_small_numbers
      assert_equal "AACKA", Base64VLQCoder.encode([0,0,1,5,0])
      assert_equal "IACIC", Base64VLQCoder.encode([4,0,1,4,1])
    end

    def test_negative_number
      actual = Base64VLQCoder.encode([6,0,1,-9,1])
      
      assert_equal "MACTC", actual
    end

    def test_bigger_number
      actual = Base64VLQCoder.encode([1,23,456,7])
      
      assert_equal "CuBwcO", actual
    end

    def test_big_positive_and_negative_numbers
      actual = Base64VLQCoder.encode([76891, -38817])
      
      assert_equal "2l2Ej6rC", actual
    end
    
  end
  
end
