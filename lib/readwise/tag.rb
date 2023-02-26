module Readwise
  Tag = Struct.new(
    'ReadwiseTag',
    :id,
    :name,
    keyword_init: true
  )
end
