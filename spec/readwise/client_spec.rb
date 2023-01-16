require 'readwise/client'

RSpec.describe Readwise::Client do
  it 'can be instantiated' do
    expect(Readwise::Client.new(token: 'foo')).to be_a(Readwise::Client)
  end

  it 'raises unless token is provided' do
    expect { Readwise::Client.new }.to raise_error(ArgumentError)
  end
end
