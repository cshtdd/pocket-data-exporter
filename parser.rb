require 'json'

file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data_str = File.read(file_path)

data = JSON.parse(data_str)

articles = data['list']

puts "Articles Count: #{articles.length}"

articles_by_tag = {}

articles.each do |id, info|
  tag_info = info['tags'] || { 'untagged items': nil }

  tag_info.keys.each do |tag|
    unless articles_by_tag.include?(tag)
      articles_by_tag[tag] = []
    end

    articles_by_tag[tag] << id
  end

  # puts tag_info
end

weird_ids = []

articles_by_tag.each do |tag, ids|
  puts tag

  ids.each do |id|
    # if articles[id].nil? || articles[id]['resolved_url'].nil?
    #   weird_ids << id
    # else
    #   puts '   ' + articles[id]['resolved_url']
    # end

    article_info = articles[id]
    if article_info.include?('resolved_url')
      if article_info['resolved_url'].nil?
        weird_ids << id
      else
        puts '   ' + article_info['resolved_url']
      end
    end
  end
end



puts 'Weird articles'
weird_ids.each do |id|
  puts "    #{id}"
end

