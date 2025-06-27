require 'readwise/document'
require "rspec/file_fixtures"

RSpec.describe Readwise::Document do
  let(:document_data) do
    {
      id: '123456',
      author: 'John Doe',
      category: 'article',
      created_at: '2023-01-15T10:30:00Z',
      html: '<p>This is some sample HTML content.</p>',
      image_url: 'https://example.com/image.jpg',
      location: 'new',
      notes: 'Some notes about this document',
      parent_id: nil,
      published_date: 1673780400000,
      reading_progress: 0.75,
      site_name: 'Example Site',
      source: 'web',
      source_url: 'https://example.com/article',
      summary: 'This is a summary of the article',
      tags: [],
      title: 'Sample Article Title',
      updated_at: '2023-01-16T12:00:00Z',
      url: 'https://example.com/article',
      word_count: 1200
    }
  end

  subject { described_class.new(**document_data) }

  describe '#created_at_time' do
    it 'parses created_at timestamp' do
      expect(subject.created_at_time).to eq(Time.parse('2023-01-15T10:30:00Z'))
    end

    it 'returns nil when created_at is nil' do
      document = described_class.new(**document_data.merge(created_at: nil))
      expect(document.created_at_time).to be_nil
    end
  end

  describe '#updated_at_time' do
    it 'parses updated_at timestamp' do
      expect(subject.updated_at_time).to eq(Time.parse('2023-01-16T12:00:00Z'))
    end

    it 'returns nil when updated_at is nil' do
      document = described_class.new(**document_data.merge(updated_at: nil))
      expect(document.updated_at_time).to be_nil
    end
  end

  describe '#published_date_time' do
    it 'converts milliseconds timestamp to Time' do
      expect(subject.published_date_time).to eq(Time.at(1673780400))
    end

    it 'returns nil when published_date is nil' do
      document = described_class.new(**document_data.merge(published_date: nil))
      expect(document.published_date_time).to be_nil
    end
  end

  describe '#read?' do
    it 'returns true when reading progress meets default threshold' do
      expect(subject.read?).to be false
      
      document = described_class.new(**document_data.merge(reading_progress: 0.85))
      expect(document.read?).to be true
    end

    it 'returns true when reading progress meets custom threshold' do
      expect(subject.read?(threshold: 0.5)).to be true
      expect(subject.read?(threshold: 0.8)).to be false
    end
  end

  describe 'parent/child methods' do
    describe '#parent?' do
      it 'returns true when parent_id is nil' do
        expect(subject.parent?).to be true
      end

      it 'returns false when parent_id is present' do
        document = described_class.new(**document_data.merge(parent_id: '789'))
        expect(document.parent?).to be false
      end
    end

    describe '#child?' do
      it 'returns false when parent_id is nil' do
        expect(subject.child?).to be false
      end

      it 'returns true when parent_id is present' do
        document = described_class.new(**document_data.merge(parent_id: '789'))
        expect(document.child?).to be true
      end
    end
  end

  describe 'location methods' do
    describe '#in_new?' do
      it 'returns true when location is new' do
        expect(subject.in_new?).to be true
      end

      it 'returns false when location is not new' do
        document = described_class.new(**document_data.merge(location: 'later'))
        expect(document.in_new?).to be false
      end
    end

    describe '#in_later?' do
      it 'returns false when location is new' do
        expect(subject.in_later?).to be false
      end

      it 'returns true when location is later' do
        document = described_class.new(**document_data.merge(location: 'later'))
        expect(document.in_later?).to be true
      end
    end

    describe '#in_archive?' do
      it 'returns false when location is new' do
        expect(subject.in_archive?).to be false
      end

      it 'returns true when location is archive' do
        document = described_class.new(**document_data.merge(location: 'archive'))
        expect(document.in_archive?).to be true
      end
    end
  end

  describe 'category methods' do
    describe '#article?' do
      it 'returns true when category is article' do
        expect(subject.article?).to be true
      end

      it 'returns false when category is not article' do
        document = described_class.new(**document_data.merge(category: 'pdf'))
        expect(document.article?).to be false
      end
    end

    describe '#pdf?' do
      it 'returns false when category is article' do
        expect(subject.pdf?).to be false
      end

      it 'returns true when category is pdf' do
        document = described_class.new(**document_data.merge(category: 'pdf'))
        expect(document.pdf?).to be true
      end
    end

    describe '#epub?' do
      it 'returns false when category is article' do
        expect(subject.epub?).to be false
      end

      it 'returns true when category is epub' do
        document = described_class.new(**document_data.merge(category: 'epub'))
        expect(document.epub?).to be true
      end
    end

    describe '#tweet?' do
      it 'returns false when category is article' do
        expect(subject.tweet?).to be false
      end

      it 'returns true when category is tweet' do
        document = described_class.new(**document_data.merge(category: 'tweet'))
        expect(document.tweet?).to be true
      end
    end

    describe '#video?' do
      it 'returns false when category is article' do
        expect(subject.video?).to be false
      end

      it 'returns true when category is video' do
        document = described_class.new(**document_data.merge(category: 'video'))
        expect(document.video?).to be true
      end
    end

    describe '#book?' do
      it 'returns false when category is article' do
        expect(subject.book?).to be false
      end

      it 'returns true when category is book' do
        document = described_class.new(**document_data.merge(category: 'book'))
        expect(document.book?).to be true
      end
    end

    describe '#email?' do
      it 'returns false when category is article' do
        expect(subject.email?).to be false
      end

      it 'returns true when category is email' do
        document = described_class.new(**document_data.merge(category: 'email'))
        expect(document.email?).to be true
      end
    end

    describe '#rss?' do
      it 'returns false when category is article' do
        expect(subject.rss?).to be false
      end

      it 'returns true when category is rss' do
        document = described_class.new(**document_data.merge(category: 'rss'))
        expect(document.rss?).to be true
      end
    end

    describe '#highlight?' do
      it 'returns false when category is article' do
        expect(subject.highlight?).to be false
      end

      it 'returns true when category is highlight' do
        document = described_class.new(**document_data.merge(category: 'highlight'))
        expect(document.highlight?).to be true
      end
    end

    describe '#note?' do
      it 'returns false when category is article' do
        expect(subject.note?).to be false
      end

      it 'returns true when category is note' do
        document = described_class.new(**document_data.merge(category: 'note'))
        expect(document.note?).to be true
      end
    end
  end

  describe '#serialize' do
    it 'returns a hash representation' do
      result = subject.serialize
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq('123456')
      expect(result[:title]).to eq('Sample Article Title')
    end
  end
end

RSpec.describe Readwise::DocumentCreate do
  let(:create_data) do
    {
      author: 'Test Author',
      category: 'article',
      html: '<p>Test content</p>',
      image_url: 'https://example.com/image.jpg',
      location: 'new',
      notes: 'Test notes',
      published_date: 1673780400000,
      saved_using: 'api',
      should_clean_html: true,
      summary: 'Test summary',
      tags: ['tag1', 'tag2'],
      title: 'Test Title',
      url: 'https://example.com/test'
    }
  end

  subject { described_class.new(**create_data) }

  describe '#serialize' do
    it 'returns compacted hash without nil values' do
      result = subject.serialize
      expect(result).to be_a(Hash)
      expect(result.keys).not_to include(nil)
      expect(result[:title]).to eq('Test Title')
      expect(result[:url]).to eq('https://example.com/test')
    end

    it 'excludes nil values from serialization' do
      document = described_class.new(title: 'Test', url: 'https://example.com', notes: nil)
      result = document.serialize
      expect(result).not_to have_key(:notes)
      expect(result[:title]).to eq('Test')
    end
  end
end