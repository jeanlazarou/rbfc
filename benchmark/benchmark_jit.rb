require 'benchmark'

require 'stringio'

require 'rbfc/compiler'
require 'rbfc/optimizer'
require 'rbfc/tokenizer'
require 'rbfc/virtual_machine'
require 'rbfc/jit_virtual_machine'

module RBFC
  input = StringIO.new("a" * 40000)
  source = StringIO.new(',[.[-],]') # cat program

  tokenizer = Tokenizer.new(source)
  compiled = Compiler.new.compile(tokenizer)
  optimized = Optimizer.new.optimize(compiled)

  Benchmark.bm(30) do |b|

    vm = VirtualMachine.new(compiled, input, StringIO.new)

    b.report 'No optimization' do
      vm.run
    end

    input.rewind

    vm = JITVirtualMachine.new(compiled, input, StringIO.new)

    b.report 'Compiled + JIT compilation' do
      vm.run
    end

    input.rewind

    vm = VirtualMachine.new(optimized, input, StringIO.new)

    b.report 'With optimization' do
      vm.run
    end

    input.rewind

    vm = JITVirtualMachine.new(optimized, input, StringIO.new)

    b.report 'Optimized + JIT compilation' do
      vm.run
    end

    input.rewind

  end

end
