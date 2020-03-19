require 'json'

module Pocket
  class Parser
    def self.articles_with_url(data_str)
      data = JSON.parse(data_str)
      data['list']
        .values
        .filter { |a| a['status'] == '0' }
        .filter { |a| a.include?('resolved_url') }
        .reject { |a| a['resolved_url'].nil? || a['resolved_url'].empty? }
    end

    def self.article_urls_by_tag(data_str)
      articles_by_tag = {}

      articles_with_url(data_str).each do |article|
        tag_info = article['tags'] || { 'untagged items': nil }

        tag_info.keys.each do |tag|
          unless articles_by_tag.include?(tag)
            articles_by_tag[tag] = []
          end

          articles_by_tag[tag] << article['resolved_url']
        end
      end

      articles_by_tag
    end

    def self.article_urls(data_str)
      articles_with_url(data_str)
        .map { |article| article['resolved_url'] }
        .uniq
    end
  end
end