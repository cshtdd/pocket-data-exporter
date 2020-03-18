require './lib/pocket_parser'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)
articles_by_tag = PocketParser.articles_by_tag(data_str)

total_count = articles_by_tag.values.flatten.uniq.count
puts "Total Count: #{total_count}"


articles_by_tag.each do |tag, urls|
  puts tag

  urls.each do |url|
    puts '   ' + url
  end
end
