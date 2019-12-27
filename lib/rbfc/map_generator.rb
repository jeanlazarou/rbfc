
require 'json'

require 'rbfc/base64_vlq_coder'

module RBFC
  class MapGenerator

    def create filename, code, js_name
      
      state = OpenStruct.new

      state.previous = 0
      state.mappings = []

      code.mappings.reduce(state) do |state, mapping|
        source_line, source_col, bytecode_index = mapping
        
        state.mappings << if source_line.nil?
          ""
        else
          offset = bytecode_index - state.previous
          state.previous = bytecode_index
          
          Base64VLQCoder.encode([source_col, 0, offset, 0])
        end

        state
      end
      
      {
        version: 3,
        file: js_name,
        sources: [File.basename(filename)],
        mappings: state.mappings.join(";"),
        sourcesContent: [code.source.join]
      }
      
    end
    
    def write filename, code, js_name, destination

      map_content = create(filename, code, js_name)
      
      File.open(destination, "w").write(map_content.to_json);

    end

  end
end
