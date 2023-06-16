module Readwise
  Tag = Struct.new(
    'ReadwiseTag',
    :tag_id,
    :name,
    keyword_init: true
  ) do
    def serialize
      to_h
    end
  end
end
