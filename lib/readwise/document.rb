require 'time'

module Readwise
  Document = Struct.new(
    'ReadwiseDocument',
    :author,
    :category,  # One of: article, email, rss, highlight, note, pdf, epub, tweet or video.
                # Default is guessed based on the URL, usually article.
    :created_at,
    :html,
    :id,
    :image_url,
    :location,  # One of: new, later, archive or feed. Default is new.
    :notes,
    :published_date,
    :reading_progress,
    :site_name,
    :source,
    :source_url,
    :summary,
    :tags,
    :title,
    :updated_at,
    :url,
    :word_count,
    :parent_id, # both highlights and notes made in Reader are also considered Documents.
                # Highlights and notes will have `parent_id` set, which is the Document id
                # of the article/book/etc and highlight that they belong to, respectively.
    keyword_init: true
  ) do
    def created_at_time
      return unless created_at

      Time.parse(created_at)
    end

    def updated_at_time
      return unless updated_at

      Time.parse(updated_at)
    end

    def published_date_time
      return unless published_date

      Time.at(published_date/1000)
    end

    def read?(threshold: 0.85)
      reading_progress >= threshold
    end

    def parent?
      parent_id.nil?
    end

    def child?
      !parent?
    end

    def in_new?
      location == 'new'
    end

    def in_later?
      location == 'later'
    end

    def in_archive?
      location == 'archive'
    end

    def pdf?
      category == 'pdf'
    end

    def epub?
      category == 'epub'
    end

    def tweet?
      category == 'tweet'
    end

    def video?
      category == 'video'
    end

    def article?
      category == 'article'
    end

    def book?
      category == 'book'
    end

    def email?
      category == 'email'
    end

    def rss?
      category == 'rss'
    end

    def highlight?
      category == 'highlight'
    end

    def note?
      category == 'note'
    end

    def serialize
      to_h
    end
  end

  DocumentCreate = Struct.new(
    'ReadwiseDocumentCreate',
    :author,
    :category,  # One of: article, email, rss, highlight, note, pdf, epub, tweet or video.
                # Default is guessed based on the URL, usually article.
    :html,
    :image_url,
    :location,  # One of: new, later, archive or feed. Default is new.
    :notes,
    :published_date,
    :saved_using,
    :should_clean_html,
    :summary,
    :tags,
    :title,
    :url,
    keyword_init: true
  ) do
    def serialize
      to_h.compact
    end
  end
end
