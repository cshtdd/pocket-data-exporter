require './lib/pocket/parser'
require './lib/pocket/formatter'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)
articles_by_tag = Pocket::Parser.article_urls_by_tag(data_str)

puts Pocket::Formatter.unique_dict_values_plaintext(articles_by_tag)
puts Pocket::Formatter.dict_to_plaintext(articles_by_tag)
