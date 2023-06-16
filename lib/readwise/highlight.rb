require 'time'

module Readwise
  Highlight = Struct.new(
    'ReadwiseHighlight',
    :book_id,
    :color,
    :created_at,
    :end_location,
    :external_id,
    :highlight_id,
    :highlighted_at,
    :is_discard,
    :is_favorite,
    :location,
    :location_type,
    :note,
    :readwise_url,
    :tags,
    :text,
    :updated_at,
    :url,
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

    def highlighted_at_time
      return unless highlighted_at

      Time.parse(highlighted_at)
    end

    def serialize
      to_h
    end
  end

  HighlightCreate = Struct.new(
    'ReadwiseHighlightCreate',
    :author,
    :category,  # One of: books, articles, tweets or podcasts.
                # (default: articles when source_url is provided, otherwise: books)
    :highlight_url,
    :highlighted_at,
    :image_url,
    :location,
    :location_type, # One of: page, order or time_offset (default: order)
    :note,
    :source_type,
    :source_url,
    :text,
    :title,
    keyword_init: true
  ) do
    def serialize
      to_h.compact
    end
  end

  HighlightUpdate = Struct.new(
    'ReadwiseHighlightUpdate',
    :color,
    :location,
    :note,
    :text,
    :url,
    keyword_init: true
  ) do
    def serialize
      to_h.compact
    end
  end
end
