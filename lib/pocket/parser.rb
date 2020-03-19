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

    def self.archived_articles_with_url(data_str)
      data = JSON.parse(data_str)
      data['list']
        .values
        .filter { |a| a['status'] == '1' }
        .filter { |a| a.include?('resolved_url') }
        .reject { |a| a['resolved_url'].nil? || a['resolved_url'].empty? }
    end

    def self.deleted_articles_with_url(data_str)
      data = JSON.parse(data_str)
      data['list']
        .values
        .filter { |a| a['status'] == '2' }
        .filter { |a| a.include?('resolved_url') }
        .reject { |a| a['resolved_url'].nil? || a['resolved_url'].empty? }
    end

    def self.urls_by_tag(articles)
      articles_by_tag = {}

      articles.each do |article|
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

    def self.urls(articles)
      articles
        .map { |article| article['resolved_url'] }
        .uniq
    end
  end
end