require 'readwise/client'
require 'readwise/highlight'
require "rspec/file_fixtures"

RSpec.describe Readwise::Client do
  it 'can be instantiated' do
    expect(Readwise::Client.new(token: 'foo')).to be_a(Readwise::Client)
  end

  it 'raises unless token is provided' do
    expect { Readwise::Client.new }.to raise_error(ArgumentError)
  end

  context 'exporting data' do
    subject { Readwise::Client.new(token: 'foo') }
    let(:export_response) { fixture('export.json').from_json(false) }

    it 'can parse export data' do
      expect(subject).to receive(:get_export_page).and_return(export_response)

      subject.export
    end
  end

  context 'retrieving a highlight' do
    subject { Readwise::Client.new(token: 'foo') }
    let(:highlight_response) { Readwise::Highlight.new }

    it 'can parse highlight data' do
      expect(subject).to receive(:get_highlight).and_return(highlight_response)

      subject.get_highlight
    end
  end
end
