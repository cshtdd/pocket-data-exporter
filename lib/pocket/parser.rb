require 'json'

module Pocket
  class Parser
    def self.articles(data_str, status = :default)
      api_status = convert_status(status)

      data = JSON.parse(data_str)
      data['list']
        .values
        .filter { |a| a['status'] == api_status }
        .filter { |a| a.include?('resolved_url') }
        .reject { |a| a['resolved_url'].nil? || a['resolved_url'].empty? }
    end

    def self.urls_by_tag(articles)
      articles_by_tag = {}

      articles.each do |article|
        tag_info = article['tags'] || {'untagged items': nil}

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

    def self.convert_status(status)
      case (status || '').to_s.downcase
      when 'deleted'
        '2'
      when 'archived'
        '1'
      else
        '0'
      end
    end
  end
end