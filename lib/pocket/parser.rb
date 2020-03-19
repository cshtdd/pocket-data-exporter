require 'json'

module Pocket
  class Parser
    def self.articles_by_tag(data_str)
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

          articles_by_tag[tag] << info['resolved_url']
        end
      end

      articles_by_tag
    end

    def self.article_urls(data_str)
      data = JSON.parse(data_str)
      articles = data['list']

      articles
        .values
        .filter { |a| a['status'] == '0' }
        .filter { |a| a.include?('resolved_url') }
        .reject { |a| a['resolved_url'].nil? || a['resolved_url'].empty? }
        .map { |a| a['resolved_url'] }
        .uniq
    end
  end
end