puts 'Export Pocket Articles'  

consumer_key = ENV['CONSUMER_KEY'] || ''
puts "Consumer Key: #{consumer_key}"

if consumer_key.empty?
  puts 'ERROR: Consumer Key missing'
  exit 1
end

puts 'Export Completed'
