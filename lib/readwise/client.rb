require 'json'
require 'net/http'
require_relative 'book'
require_relative 'highlight'
require_relative 'tag'

module Readwise
  class Client
    class Error < StandardError; end

    BASE_URL = "https://readwise.io/api/v2/"

    def initialize(token: nil)
      raise ArgumentError unless token

      @token = token.to_s
    end

    def create_highlight(highlight:)
      create_highlights(highlights: [highlight]).first
    end

    def create_highlights(highlights: [])
      raise ArgumentError unless highlights.all? { |item| item.is_a?(Readwise::HighlightCreate) }
      return [] unless highlights.any?

      url = BASE_URL + 'highlights/'

      payload = { highlights: highlights.map(&:serialize) }
      res = post_readwise_request(url, payload: payload)

      modified_ids = res.map { |book| book['modified_highlights'] }.flatten
      modified_ids.map { |id| get_highlight(highlight_id: id) }
    end

    def get_highlight(highlight_id:)
      url = BASE_URL + "highlights/#{highlight_id}"

      res = get_readwise_request(url)

      transform_highlight(res)
    end

    def update_highlight(highlight:, update:)
      raise ArgumentError unless update.is_a?(Readwise::HighlightUpdate)

      url = BASE_URL + "highlights/#{highlight.highlight_id}"

      res = patch_readwise_request(url, payload: update.serialize)

      transform_highlight(res)
    end

    def remove_highlight_tag(highlight:, tag:)
      url = BASE_URL + "highlights/#{highlight.highlight_id}/tags/#{tag.tag_id}"

      delete_readwise_request(url)
    end

    def add_highlight_tag(highlight:, tag:)
      raise ArgumentError unless tag.is_a?(Readwise::Tag)

      url = BASE_URL + "highlights/#{highlight.highlight_id}/tags"

      payload = tag.serialize.select { |k, v| k == :name }
      res = post_readwise_request(url, payload: payload)

      transform_tag(res)
    end

    def update_highlight_tag(highlight:, tag:)
      raise ArgumentError unless tag.is_a?(Readwise::Tag)

      url = BASE_URL + "highlights/#{highlight.highlight_id}/tags/#{tag.tag_id}"

      payload = tag.serialize.select { |k, v| k == :name }
      res = patch_readwise_request(url, payload: payload)

      transform_tag(res)
    end

    def get_book(book_id:)
      url = BASE_URL + "books/#{book_id}"

      res = get_readwise_request(url)

      transform_book(res)
    end

    def export(updated_after: nil, book_ids: [])
      resp = export_page(updated_after: updated_after, book_ids: book_ids)
      next_page_cursor = resp[:next_page_cursor]
      results = resp[:results]
      while next_page_cursor
        resp = export_page(updated_after: updated_after, book_ids: book_ids, page_cursor: next_page_cursor)
        results.concat(resp[:results])
        next_page_cursor = resp[:next_page_cursor]
      end
      results.sort_by(&:highlighted_at_time)
    end

    private

    def export_page(page_cursor: nil, updated_after: nil, book_ids: [])
      parsed_body = get_export_page(page_cursor: page_cursor, updated_after: updated_after, book_ids: book_ids)
      results = parsed_body.dig('results').map do |item|
        transform_book(item)
      end
      {
        results: results,
        next_page_cursor: parsed_body.dig('nextPageCursor')
      }
    end

    def get_export_page(page_cursor: nil, updated_after: nil, book_ids: [])
      params = {}
      params['updatedAfter'] = updated_after if updated_after
      params['ids'] = book_ids if book_ids.any?
      params['pageCursor'] = page_cursor if page_cursor
      url = BASE_URL + 'export/?' + URI.encode_www_form(params)

      get_readwise_request(url)

    end

    def transform_book(res)
      highlights = (res['highlights'] || []).map { |highlight| transform_highlight(highlight) }
      Book.new(
        asin: res['asin'],
        author: res['author'],
        book_id: res['user_book_id'].to_s,
        category: res['category'],
        cover_image_url: res['cover_image_url'],
        note: res['document_note'],
        readable_title: res['readable_title'],
        readwise_url: res['readwise_url'] || res['highlights_url'],
        source: res['source'],
        source_url: res['source_url'],
        tags: (res['book_tags'] || res['tags'] || []).map { |tag| transform_tag(tag) },
        title: res['title'],
        unique_url: res['unique_url'],
        highlights: highlights,
        num_highlights: res['num_highlights'] || highlights.size,
      )
    end

    def transform_highlight(res)
      Highlight.new(
        book_id: res['book_id'].to_s,
        color: res['color'],
        created_at: res['created_at'],
        end_location: res['end_location'],
        external_id: res['external_id'],
        highlight_id: res['id'].to_s,
        highlighted_at: res['highlighted_at'],
        is_discard: res['is_discard'],
        is_favorite: res['is_favorite'],
        location: res['location'],
        location_type: res['location_type'],
        note: res['note'],
        readwise_url: res['readwise_url'],
        tags: res['tags'].map { |tag| transform_tag(tag) },
        text: res['text'],
        updated_at: res['updated_at'],
        url: res['url'],
      )
    end

    def transform_tag(res)
      Tag.new(
        tag_id: res['id'].to_s,
        name: res['name'],
      )
    end

    def get_readwise_request(url)
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Token #{@token}"
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      raise Error, 'Get request failed' unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body)
    end

    def patch_readwise_request(url, payload:)
      uri = URI.parse(url)
      req = Net::HTTP::Patch.new(uri)
      req['Authorization'] = "Token #{@token}"
      req['Content-Type'] = 'application/json'
      req.body = payload.to_json
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      raise Error, 'Patch request failed' unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body)
    end

    def post_readwise_request(url, payload:)
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri)
      req['Authorization'] = "Token #{@token}"
      req['Content-Type'] = 'application/json'
      req.body = payload.to_json
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      raise Error, 'Post request failed' unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body)
    end

    def delete_readwise_request(url)
      uri = URI.parse(url)
      req = Net::HTTP::Delete.new(uri)
      req['Authorization'] = "Token #{@token}"
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      raise Error, 'Delete request failed' unless res.is_a?(Net::HTTPSuccess)
    end
  end
end
