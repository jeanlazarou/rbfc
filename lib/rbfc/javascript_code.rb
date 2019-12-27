module RBFC

  class JavascriptCode

    attr_accessor :source
    attr_reader :name, :code, :mappings
    
    def initialize name, code, mappings
      @name = name
      @code = code
      @mappings = mappings
    end
    
  end
  
end
