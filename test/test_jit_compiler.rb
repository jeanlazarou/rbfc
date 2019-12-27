require_relative 'test_helper'

require 'rbfc/jit_virtual_machine'

require 'rbfc/compiler'
require 'rbfc/optimizer'
require 'rbfc/tokenizer'

module RBFC

  class JITCompilerTests < Minitest::Test

    def test_forward_jump
      output = StringIO.new
      input = StringIO.new("7")

      jit_run(',>[,.]<.', input, output)

      assert_equal "7", output.string
    end

    def test_optimized_forward_jump
      output = StringIO.new
      input = StringIO.new("7")

      jit_run(',>[,.]<.', input, output, :optimize)

      assert_equal "7", output.string
    end

    def test_backward_jump
      output = StringIO.new
      input = StringIO.new("13")

      jit_run(',[.,.>]', input, output)

      assert_equal "13", output.string
    end

    def test_optimized_backward_jump
      output = StringIO.new
      input = StringIO.new("13")

      jit_run(',[.,.>]', input, output, :optimize)

      assert_equal "13", output.string
    end


    def test_add_sub_and_move
      output = StringIO.new
      input = StringIO.new("1358")

      jit_run(',++++>,+>,->,-----<<<.>.>.>.<<<.>>>.', input, output)

      assert_equal "544353", output.string
    end

    def test_optimized_add_sub_and_move
      output = StringIO.new
      input = StringIO.new("1358")

      jit_run(',++++>,+>,->,-----<<<.>.>.>.<<<.>>>.', input, output, :optimize)

      assert_equal "544353", output.string
    end

    def test_cat_example
      output = StringIO.new
      input = StringIO.new("Please, do not fail...")

      jit_run(',[.[-],]', input, output)

      assert_equal "Please, do not fail...", output.string
    end

    def test_optimized_cat_example
      output = StringIO.new
      input = StringIO.new("Please, do not fail...")

      jit_run(',[.[-],]', input, output, :optimize)

      assert_equal "Please, do not fail...", output.string
    end

    def jit_run source, input, output, type = :default
      source = StringIO.new(source)

      tokenizer = RBFC::Tokenizer.new(source)
      compiled = RBFC::Compiler.new.compile(tokenizer)

      compiled = RBFC::Optimizer.new.optimize(compiled) if type == :optimize

      vm = RBFC::JITVirtualMachine.new(compiled, input, output)

      vm.run
    end

  end

end
