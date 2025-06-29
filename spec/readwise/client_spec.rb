require 'readwise/client'
require 'readwise/highlight'
require 'readwise/document'
require "rspec/file_fixtures"

RSpec.describe Readwise::Client do
  subject { Readwise::Client.new(token: 'foo') }

  it 'can be instantiated' do
    expect(subject).to be_a(Readwise::Client)
  end

  it 'raises unless token is provided' do
    expect { Readwise::Client.new }.to raise_error(ArgumentError)
  end

  context 'exporting data' do
    let(:export_response) { fixture('export.json').from_json(false) }

    it 'can parse export data' do
      expect(subject).to receive(:get_export_page).and_return(export_response)

      subject.export
    end
  end

  context 'retrieving a highlight' do
    let(:highlight_response) { fixture('highlight.json').from_json(false) }

    it 'can parse highlight data' do
      expect(subject).to receive(:get_readwise_request).and_return(highlight_response)

      highlight = subject.get_highlight(highlight_id: "12345")
      expect(highlight).to be_instance_of Readwise::Highlight
    end
  end

  context 'creating a highlight' do
    let(:highlight_create_response) { fixture('highlight_create.json').from_json(false) }
    let(:highlight_response) { fixture('highlight.json').from_json(false) }

    it 'can create a highlight' do
      expect(subject).to receive(:post_readwise_request).and_return(highlight_create_response)
      expect(subject).to receive(:get_readwise_request).and_return(highlight_response)

      create_req = Readwise::HighlightCreate.new(text: 'foobar')
      highlight = subject.create_highlight(highlight: create_req)
      expect(highlight).to be_instance_of Readwise::Highlight
    end

    it 'can create a set of highlights' do
      expect(subject).to receive(:post_readwise_request).and_return(highlight_create_response)
      expect(subject).to receive(:get_readwise_request).and_return(highlight_response)

      create_req = Readwise::HighlightCreate.new(text: 'foobar')
      highlights = subject.create_highlights(highlights: [create_req])
      expect(highlights.first).to be_instance_of Readwise::Highlight
      expect(highlights.size).to eq(1)
    end
  end

  context 'tagging a highlight' do
    let(:tag_response) { fixture('tag.json').from_json(false) }

    it 'can add a tag to a highlight' do
      expect(subject).to receive(:post_readwise_request).and_return(tag_response)

      highlight = Readwise::Highlight.new(text: 'foobar')
      tag = Readwise::Tag.new(name: 'foobar')
      result = subject.add_highlight_tag(highlight: highlight, tag: tag)
      expect(result).to be_instance_of Readwise::Tag
    end

    it 'can remove a tag from a highlight' do
      expect(subject).to receive(:delete_readwise_request)

      highlight = Readwise::Highlight.new(text: 'foobar')
      tag = Readwise::Tag.new(name: 'foobar', tag_id: '12')
      result = subject.remove_highlight_tag(highlight: highlight, tag: tag)
      expect(result).to be_nil
    end

    it 'can update a tag on a highlight' do
      expect(subject).to receive(:patch_readwise_request).and_return(tag_response)

      highlight = Readwise::Highlight.new(text: 'foobar')
      tag = Readwise::Tag.new(name: 'foobar', tag_id: '12')
      result = subject.update_highlight_tag(highlight: highlight, tag: tag)
      expect(result).to be_instance_of Readwise::Tag
    end
  end

  context 'retrieving a book' do
    let(:book_response) { fixture('book.json').from_json(false) }

    it 'can parse book data' do
      expect(subject).to receive(:get_readwise_request).and_return(book_response)

      book = subject.get_book(book_id: "12345")
      expect(book).to be_instance_of Readwise::Book
    end
  end

  context 'documents (V3 API)' do
    context 'creating a document' do
      let(:document_create_response) { fixture('document_create.json').from_json(false) }
      let(:document_response) { { 'results' => [fixture('document.json').from_json(false)] } }

      it 'can create a document' do
        expect(subject).to receive(:post_readwise_request).and_return(document_create_response)
        expect(subject).to receive(:get_readwise_request).and_return(document_response)

        create_req = Readwise::DocumentCreate.new(
          title: 'Test Document',
          url: 'https://example.com/test'
        )
        document = subject.create_document(document: create_req)
        expect(document).to be_instance_of Readwise::Document
      end

      it 'raises error when document is not DocumentCreate instance' do
        expect { subject.create_document(document: 'invalid') }.to raise_error(ArgumentError)
      end

      it 'can create multiple documents' do
        expect(subject).to receive(:post_readwise_request).twice.and_return(document_create_response)
        expect(subject).to receive(:get_readwise_request).twice.and_return(document_response)

        create_req1 = Readwise::DocumentCreate.new(title: 'Test 1', url: 'https://example.com/1')
        create_req2 = Readwise::DocumentCreate.new(title: 'Test 2', url: 'https://example.com/2')

        documents = subject.create_documents(documents: [create_req1, create_req2])
        expect(documents).to be_an(Array)
        expect(documents.size).to eq(2)
        expect(documents.first).to be_instance_of Readwise::Document
      end

      it 'returns empty array when no documents provided' do
        result = subject.create_documents(documents: [])
        expect(result).to eq([])
      end
    end

    context 'retrieving a document' do
      let(:document_response) { { 'results' => [fixture('document.json').from_json(false)] } }

      it 'can retrieve a single document' do
        expect(subject).to receive(:get_readwise_request).and_return(document_response)

        document = subject.get_document(document_id: '123456')
        expect(document).to be_instance_of Readwise::Document
        expect(document.id).to eq('123456')
      end
    end

    context 'retrieving documents' do
      let(:page1_response) { fixture('document_list.json').from_json(false) }
      let(:page2_response) { { 'results' => [], 'nextPageCursor' => nil } }

      it 'can retrieve all documents' do
        expect(subject).to receive(:get_documents_page).and_return(page1_response)

        documents = subject.get_documents
        expect(documents).to be_an(Array)
        expect(documents.size).to eq(2)
        expect(documents.first).to be_instance_of Readwise::Document
      end

      it 'handles pagination correctly' do
        page1_with_cursor = page1_response.merge('nextPageCursor' => 'cursor123')

        expect(subject).to receive(:get_documents_page)
          .with(updated_after: nil, location: nil, category: nil, page_cursor: nil)
          .and_return(page1_with_cursor)

        expect(subject).to receive(:get_documents_page)
          .with(updated_after: nil, location: nil, category: nil, page_cursor: 'cursor123')
          .and_return(page2_response)

        documents = subject.get_documents
        expect(documents).to be_an(Array)
        expect(documents.size).to eq(2)
      end

      it 'sorts documents by created_at' do
        expect(subject).to receive(:get_documents_page).and_return(page1_response)

        documents = subject.get_documents
        created_times = documents.map(&:created_at_time).compact
        expect(created_times).to eq(created_times.sort)
      end

      it 'passes filter parameters' do
        expect(subject).to receive(:get_documents_page)
          .with(updated_after: '2023-01-01', location: 'new', category: 'article', page_cursor: nil)
          .and_return(page1_response)

        subject.get_documents(updated_after: '2023-01-01', location: 'new', category: 'article')
      end
    end

    context 'transform methods' do
      it 'transforms document with array tags' do
        document_data = fixture('document.json').from_json(false)
        result = subject.send(:transform_document, document_data)

        expect(result).to be_instance_of Readwise::Document
        expect(result.tags).to be_an(Array)
        expect(result.tags.first).to be_instance_of Readwise::Tag
      end

      it 'transforms document with hash tags' do
        document_data = fixture('document_list.json').from_json(false)['results'][1]
        result = subject.send(:transform_document, document_data)

        expect(result).to be_instance_of Readwise::Document
        expect(result.tags).to be_an(Array)
      end

      it 'transforms document with string tags' do
        document_data = fixture('document_tags_string.json').from_json(false)
        result = subject.send(:transform_document, document_data)

        expect(result).to be_instance_of Readwise::Document
        expect(result.tags).to be_an(Array)
        expect(result.tags.first).to be_instance_of Readwise::Tag
        expect(result.tags.first.name).to eq('tag1')
      end

      it 'handles empty tags' do
        document_data = fixture('document.json').from_json(false).merge('tags' => nil)
        result = subject.send(:transform_document, document_data)

        expect(result).to be_instance_of Readwise::Document
        expect(result.tags).to eq([])
      end
    end

    context 'transform_tags method' do
      it 'transforms array of tag objects' do
        tags_data = [
          { 'id' => 'tag1', 'name' => 'technology' },
          { 'id' => 'tag2', 'name' => 'programming' }
        ]

        result = subject.send(:transform_tags, tags_data)
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result.first).to be_instance_of Readwise::Tag
        expect(result.first.name).to eq('technology')
      end

      it 'transforms hash of tags' do
        tags_data = {
          'tag1' => { 'name' => 'technology' },
          'tag2' => { 'name' => 'programming' }
        }

        result = subject.send(:transform_tags, tags_data)
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result.first).to be_instance_of Readwise::Tag
        expect(result.first.tag_id).to eq('tag1')
      end

      it 'transforms array of strings' do
        tags_data = ['tag1', 'tag2', 'tag3']

        result = subject.send(:transform_tags, tags_data)
        expect(result).to be_an(Array)
        expect(result.size).to eq(3)
        expect(result.first).to be_instance_of Readwise::Tag
        expect(result.first.name).to eq('tag1')
      end

      it 'returns empty array for invalid input' do
        result = subject.send(:transform_tags, 'invalid')
        expect(result).to eq([])
      end

      it 'returns empty array for nil input' do
        result = subject.send(:transform_tags, nil)
        expect(result).to eq([])
      end
    end
  end

  context 'error handling' do
    it 'raises error with status code on failed GET request' do
      allow(Net::HTTP).to receive(:start).and_return(double(code: '404', is_a?: false))

      expect { subject.send(:get_readwise_request, 'https://example.com') }
        .to raise_error(Readwise::Client::Error, 'Get request failed with status code: 404')
    end

    it 'raises error on failed POST request' do
      allow(Net::HTTP).to receive(:start).and_return(double(is_a?: false))

      expect { subject.send(:post_readwise_request, 'https://example.com', payload: {}) }
        .to raise_error(Readwise::Client::Error, 'Post request failed')
    end

    it 'raises error on failed PATCH request' do
      allow(Net::HTTP).to receive(:start).and_return(double(is_a?: false))

      expect { subject.send(:patch_readwise_request, 'https://example.com', payload: {}) }
        .to raise_error(Readwise::Client::Error, 'Patch request failed')
    end

    it 'raises error on failed DELETE request' do
      allow(Net::HTTP).to receive(:start).and_return(double(is_a?: false))

      expect { subject.send(:delete_readwise_request, 'https://example.com') }
        .to raise_error(Readwise::Client::Error, 'Delete request failed')
    end
  end
end
