module Readwise
  Tag = Struct.new(
    'ReadwiseTag',
    :tag_id,
    :name,
    keyword_init: true
  )
end
