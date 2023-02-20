require 'readwise/client'
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
end
