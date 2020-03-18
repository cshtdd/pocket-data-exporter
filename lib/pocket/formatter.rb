module Pocket
  class Formatter
    def self.unique_dict_values_plaintext(hash)
      total_count = hash.values.flatten.uniq.count
      "Total Count: #{total_count}"
    end

    def self.dict_to_plaintext(hash)
      result = ''

      hash.each do |key, values|
        result << "#{key}\r\n"

        values.each do |url|
          result << "    #{url}\r\n"
        end
      end

      result
    end
  end
end