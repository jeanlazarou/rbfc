require 'rbfc/jit_compiler'

module RBFC

  class JITVirtualMachine

    def initialize bytecode, input = $stdin, output = $stdout
      @bytecode = bytecode
      @input, @output = input, output
    end

    def run
      compiled = RBFC::JITCompiler.new.compile(@bytecode)

      ruby_code = "def run(input, output)\n#{compiled}\nend"

      dynamic_vm = Class.new
      dynamic_vm.module_eval(ruby_code)

      dynamic_vm.new.run @input, @output
    end

  end

end
