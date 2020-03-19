require './lib/pocket/parser'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)
articles = Pocket::Parser.articles(data_str, :default)
articles_by_tag = Pocket::Parser.urls_by_tag(articles)

total_count = articles_by_tag.values.flatten.uniq.count
puts "Total Count: #{total_count}"

articles_by_tag.each do |key, values|
  puts key.to_s

  values.each do |url|
    puts "    #{url}"
  end
end