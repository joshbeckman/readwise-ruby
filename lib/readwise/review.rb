module Readwise
  Review = Struct.new(
    :id,
    :url,
    :completed,
    :highlights,
    keyword_init: true
  ) do
    def completed?
      completed
    end

    def serialize
      to_h.compact
    end
  end
end