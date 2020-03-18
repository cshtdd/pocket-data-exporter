require 'json'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)

data = JSON.parse(data_str)

articles = data['list']

articles_by_tag = {}

articles.each do |id, info|
  next unless info['status'] == '0'
  next unless info.include?('resolved_url')
  next if info['resolved_url'].nil? || info['resolved_url'].empty?

  tag_info = info['tags'] || { 'untagged items': nil }

  tag_info.keys.each do |tag|
    unless articles_by_tag.include?(tag)
      articles_by_tag[tag] = []
    end

    articles_by_tag[tag] << id
  end
end


total_count = articles_by_tag.values.flatten.uniq.count
puts "Total Count: #{total_count}"


articles_by_tag.each do |tag, ids|
  puts tag

  ids.each do |id|
    puts '   ' + articles[id]['resolved_url']
  end
end
