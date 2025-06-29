require 'readwise/review'
require 'readwise/highlight'

RSpec.describe Readwise::Review do
  let(:review_data) do
    {
      id: 12345,
      url: 'https://readwise.io/review/12345',
      completed: false,
      highlights: []
    }
  end

  subject { described_class.new(**review_data) }

  describe '#completed?' do
    it 'returns false when completed is false' do
      expect(subject.completed?).to be false
    end

    it 'returns true when completed is true' do
      review = described_class.new(**review_data.merge(completed: true))
      expect(review.completed?).to be true
    end
  end

  describe '#serialize' do
    it 'returns a hash representation' do
      result = subject.serialize
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(12345)
      expect(result[:url]).to eq('https://readwise.io/review/12345')
      expect(result[:completed]).to be false
    end

    it 'excludes nil values from serialization' do
      review = described_class.new(id: 123, url: 'https://example.com', completed: nil, highlights: [])
      result = review.serialize
      expect(result).not_to have_key(:completed)
      expect(result[:id]).to eq(123)
    end
  end

  describe 'with highlights' do
    let(:highlight) { Readwise::Highlight.new(text: 'Sample highlight', highlight_id: '123', book_id: '456', tags: []) }
    let(:review_with_highlights) do
      described_class.new(**review_data.merge(highlights: [highlight]))
    end

    it 'stores highlights properly' do
      expect(review_with_highlights.highlights).to be_an(Array)
      expect(review_with_highlights.highlights.size).to eq(1)
      expect(review_with_highlights.highlights.first).to be_instance_of Readwise::Highlight
    end
  end
end