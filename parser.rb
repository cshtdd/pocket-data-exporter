require './lib/pocket_parser'
require './lib/data_formatter'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)
articles_by_tag = PocketParser.articles_by_tag(data_str)

puts DataFormatter.unique_dict_values_plaintext(articles_by_tag)
puts DataFormatter.dict_to_plaintext(articles_by_tag)
