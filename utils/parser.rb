require './lib/pocket/parser'
require './lib/pocket/formatter'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)
article_urls = Pocket::Parser.article_urls(data_str)

puts Pocket::Formatter.total_count(article_urls)
puts Pocket::Formatter.list_to_plaintext(article_urls)
