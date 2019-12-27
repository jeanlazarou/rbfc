require "rbfc/version"

require 'rbfc/compiler'
require 'rbfc/tokenizer'

require 'rbfc/virtual_machine'

module RBFC

  extend RBFC

  require 'stringio'
  require 'optparse'

  class Options

    attr_reader :program_file
    attr_reader :input_stream

    def initialize description
      @show_version = false

      optparse = OptionParser.new do|opts|
        opts.banner = "Usage: #{File.basename($0)} [options] #{description}"

        opts.on( '-v', '--version', 'Display version number' ) do
          @show_version = true
          puts "Ver. #{VERSION}"
         end

        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end

        yield opts if block_given?
      end

      rest = optparse.parse!

      @program_file = rest.shift

      unless @show_version || @program_file
        puts "No source file"
        exit 1
      end

      unless @show_version || File.file?(@program_file)
        puts "File not found '#{@program_file}'"
        exit 2
      end

      exit 0 unless @program_file

      if rest.empty?
        @input_stream = $stdin
      else
        @input_stream = StringIO.new(rest.join(' ') + "\n")
      end
    end
  end

  def compile file

    open(file) do |stream|

      tokenizer = Tokenizer.new(stream)

      Compiler.new.compile tokenizer

    end

  end

  def execute file

    program = compile(file)

    VirtualMachine.new(program).run

  end

  def self.debug file, input

    open(file) do |stream|

      tokenizer = Tokenizer.new(stream)

      debugger = Debugger.new(open(file), tokenizer, input)

      debugger.run

    end

  end
end
