require 'spec_helper'
require 'tempfile'
require 'open3'

RSpec.describe 'readwise CLI' do
  let(:cli_path) { File.expand_path('../../exe/readwise', __FILE__) }
  let(:test_html) { '<p>Test content</p>' }
  let(:temp_file) do
    file = Tempfile.new(['test', '.html'])
    file.write(test_html)
    file.close
    file
  end

  after do
    temp_file.unlink if temp_file
  end

  def run_cli(*args)
    env = { 'READWISE_API_KEY' => 'test_token' }
    Open3.capture3(env, 'ruby', cli_path, *args)
  end

  def run_cli_without_token(*args)
    env = {}
    Open3.capture3(env, 'ruby', cli_path, *args)
  end

  describe 'help and error handling' do
    it 'shows help when --help is passed' do
      stdout, _stderr, status = run_cli('--help')

      expect(status.success?).to be true
      expect(stdout).to include('Usage: readwise')
      expect(stdout).to include('Available commands:')
    end

    it 'shows help when no arguments are provided' do
      stdout, _stderr, status = run_cli()

      expect(status.success?).to be false
      expect(stdout).to include('Usage: readwise <resource> <action>')
    end

    it 'shows error for unknown command' do
      stdout, _stderr, status = run_cli('unknown', 'command')

      expect(status.success?).to be false
      expect(stdout).to include("Error: Unknown command 'unknown command'")
    end

    it 'shows error when resource or action is missing' do
      stdout, _stderr, status = run_cli('document')

      expect(status.success?).to be false
      expect(stdout).to include('Error: Resource and action are required')
    end
  end

  describe 'document create command' do
    it 'shows help for document create command' do
      stdout, _stderr, status = run_cli('document', 'create', '--help')

      expect(status.success?).to be true
      expect(stdout).to include('Usage: readwise document create')
      expect(stdout).to include('Sends HTML content to Readwise Reader API')
    end

    it 'shows error when neither a file path or URL is provided' do
      stdout, _stderr, status = run_cli('document', 'create')

      expect(status.success?).to be false
      expect(stdout).to include('Error: File path or URL is required')
    end

    it 'shows error when file does not exist' do
      stdout, _stderr, status = run_cli('document', 'create', '--html-file', 'nonexistent.html')

      expect(status.success?).to be false
      expect(stdout).to include("Error: File 'nonexistent.html' not found")
    end

    it 'shows error when READWISE_API_KEY is not set' do
      stdout, _stderr, status = run_cli_without_token('document', 'create', '--html-file', temp_file.path)

      expect(status.success?).to be false
      expect(stdout).to include('Error: READWISE_API_KEY environment variable is not set')
    end

    it 'shows error for invalid location' do
      stdout, _stderr, status = run_cli('document', 'create', '--location=invalid', '--html-file', temp_file.path)

      expect(status.success?).to be false
      expect(stdout).to include('Error: Invalid location. Must be one of: new, later, archive, feed')
    end

    it 'shows error for invalid category' do
      stdout, _stderr, status = run_cli('document', 'create', '--category=invalid', '--html-file', temp_file.path)

      expect(status.success?).to be false
      expect(stdout).to include('Error: Invalid category. Must be one of: article, email, rss, highlight, note, pdf, epub, tweet, video')
    end

    it 'shows error for invalid URL' do
      stdout, _stderr, status = run_cli('document', 'create', '--url=invalid-url', '--html-file', temp_file.path)

      expect(status.success?).to be false
      expect(stdout).to include('Error: Invalid URL format. Please provide a valid URL.')
    end

    it 'shows error for invalid date format' do
      stdout, _stderr, status = run_cli('document', 'create', '--published-date=invalid-date', '--html-file', temp_file.path)

      expect(status.success?).to be false
      expect(stdout).to include('Error: Invalid date format. Please provide a valid ISO 8601 date')
    end
  end
end
