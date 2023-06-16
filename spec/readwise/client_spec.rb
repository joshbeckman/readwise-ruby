require 'readwise/client'
require 'readwise/highlight'
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
end
