file_path = ARGV[0] || ''
unless File.exist?(file_path)
  puts 'ERROR: File not found'
  exit 1
end

data = File.read(file_path)

puts data.length

