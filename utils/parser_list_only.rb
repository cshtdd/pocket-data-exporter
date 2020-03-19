require './lib/pocket/parser'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)
articles = Pocket::Parser.articles_with_url(data_str)
article_urls = Pocket::Parser.urls(articles)

puts "Total Count: #{article_urls.length}"
article_urls.each do |s|
  puts s
end