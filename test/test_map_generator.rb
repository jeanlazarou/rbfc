require 'minitest/autorun'
require 'minitest/unit'
require 'stringio'

require 'rbfc/tokenizer'
require 'rbfc/compiler'
require 'rbfc/transpiler'

require 'rbfc/map_generator.rb'

module RBFC

  class MapGeneratorTests < Minitest::Test

    def test_map_file_for_cat_program

      code = compile(program)

      code.source = program
                      .split("\n")
                      .map(&->(line) { line + "\n" })
 
      map = MapGenerator.new.create('cat.bf', code, 'cat.bf.js')

      assert_equal(map[:version], 3)
      assert_equal(map[:file], "cat.bf.js")
      assert_equal(map[:sources], ["cat.bf"])
      assert_equal(map[:sourcesContent], [program])
      assert_equal(map[:mappings], ";;AAEA;AAIA;AACA;AACA;AACA;AACA;AAAA;AACA;AACA;AAAA")

    end

    def compile code

      tokenizer = Tokenizer.new(StringIO.new(code))

      bytecode = Compiler.new.compile(tokenizer)

      Transpiler.new.transpile("cat.bf.js", bytecode)
      
    end

    def program
      <<~BF
      ** A program that outputs the input (file)

      ,            read one character (into cell value)
                   as the default initial value is 0 and EOF does not
                   change current value
                   
      [
        .          print it (cell value content)
        [          loop until value is 0
          -        decrement value
        ]        
        ,          read next character if EOF leave 0 (unchanged)
      ]
      BF
    end

  end
  
end
