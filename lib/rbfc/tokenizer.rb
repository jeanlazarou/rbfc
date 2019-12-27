require_relative 'reader'

module RBFC

  class Tokenizer

    def initialize stream
      @stream = Reader.new(stream)
    end

    def each_token &block

      @stream.each_char do |c|

        token = to_token(c)

        block.call token if token

      end

      block.call(:eof)

    end

    def to_token c

      case c
        when '>' then :inc_pointer
        when '<' then :dec_pointer
        when '+' then :inc_value
        when '-' then :dec_value
        when '.' then :output
        when ',' then :input
        when '[' then :jump_forward
        when ']' then :jump_backward
        when '#' then :debug
        when nil then :eof
      end

    end


    attr_accessor :source_name

    def source_name

      return @source_name if @source_name

      @stream.respond_to?(:path) ? @stream.path : nil

    end

    def line
      @stream.line
    end

    def column
      @stream.column
    end

  end

end
