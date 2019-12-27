module RBFC

  class Reader

    attr_accessor :line, :column

    def initialize stream

      @stream = stream

      @line = 1
      @column = 0

    end

    def each_char &block

      @stream.each_char do |c|

        update_position c

        block.call c

      end

      block.call(:eof)

    end
    def update_position c

      return unless c

      if c == "\r"

        @line += 1
        @column = 0

        @processing_eol = true

      elsif c == "\n"

        unless @processing_eol

          @line += 1
          @column = 0

        end

        @processing_eol = false

      else

        @column += 1

        @processing_eol = false

      end

    end


  end

end
