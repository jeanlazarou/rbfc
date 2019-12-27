module RBFC

  BASE64_MAPPING =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.split('')

  class Base64VLQCoder
    def self.encode(values)
      values.map do |value|
        sign = value >= 0 ? 0x0 : 0x1
        
        value = value.abs

        if value >> 4 == 0
          BASE64_MAPPING[value << 1 | sign]
        else
          result = BASE64_MAPPING[0x20 | (value & 0xF) << 1 | sign]

          rest = value >> 4

          while rest > 0
            i = rest & 0x1F

            rest = rest >> 5

            result += BASE64_MAPPING[rest > 0 ? 0x20 | i : i]
          end

          result
        end
      end.join
    end
  end
end
