require 'rbfc/slice'
require 'rbfc/debug_shell'

module RBFC

  class Debugger

    def initialize source, tokenizer, input, console = $stdout

      bytecode = Compiler.new.compile(tokenizer)

      @shell = DebugShell.new(bytecode, source.readlines, input, console)

    end

    def run
      @shell.start
    end
    # dumps the +n+ bytes starting at +offset+ of the given +data+ array to the
    # given output stream (+out+)
    def self.dump data, offset, n, out = $stdout

      return if n < 0

      data = Slice.new(data, offset, offset + n - 1) unless data.empty?

      raise "Invalid n (size = #{data.size}, n = #{n})" if data.size < n

      buffer = ''
      buffer_chars = ''

      formatter = proc {|i| "%3d |#{buffer.ljust(40)} | #{buffer_chars}" % (offset + i) }

      if data.empty?
        out.puts formatter.call(0)
        return
      end

      n.times do |i|

        buffer << (" %3d" % data[i])
        buffer_chars << (data[i] < 32 ? '.' : data[i].chr)

        if (i % 10) == 9

          out.puts formatter.call(i - 9)

          buffer = ''
          buffer_chars = ''

        end

      end

      if n % 10 != 0

        i = (n / 10) * 10

        out.puts formatter.call(i)

      end

    end

  end

end
