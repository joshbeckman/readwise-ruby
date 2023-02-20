require 'time'

module Readwise
  Book = Struct.new(
    'ReadwiseBook',
    :asin,
    :author,
    :book_id,
    :category,
    :cover_image_url,
    :highlights,
    :note,
    :readable_title,
    :readwise_url,
    :source,
    :source_url,
    :tags,
    :title,
    :unique_url,
    keyword_init: true
  ) do

    def article?
      category == 'article'
    end

    def book?
      category == 'book'
    end

    def supplemental?
      category == 'supplemental'
    end

    def email_sourced?
      !!source_url.match(/^mailto:/)
    end

    def highlighted_at_time
      date = highlights.sort_by(&:highlighted_at).first&.highlighted_at_time
      date ||= highlights.sort_by(&:updated_at).first&.updated_at_time
      date || Time.now
    end
  end
end
