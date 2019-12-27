require 'minitest/autorun'
require 'minitest/unit'

require 'stringio'

module RBFC

  class CodeArray < Array

    attr_reader :trace

    def initialize data

      super

      @trace = []

    end

    def [] index
      @trace << index
      super
    end

  end

end
