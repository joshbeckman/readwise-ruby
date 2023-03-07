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
      create_highlights([highlight])
    end

    def create_highlights(highlights: [])
      raise NotImplementedError
    end

    def get_highlight(highlight_id:)
      url = BASE_URL + 'highlights/' + highlight_id

      res = get_readwise_request(url)

      transform_highlight(res)
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
        Book.new(
          asin: item['asin'],
          author: item['author'],
          book_id: item['user_book_id'].to_s,
          category: item['category'],
          cover_image_url: item['cover_image_url'],
          note: item['document_note'],
          readable_title: item['readable_title'],
          readwise_url: item['readwise_url'],
          source: item['source'],
          source_url: item['source_url'],
          tags: item['book_tags'].map do |tag|
            Tag.new(
              tag_id: tag['id'].to_s,
              name: tag['name']
            )
          end,
          title: item['title'],
          unique_url: item['unique_url'],
          highlights: item['highlights'].map do |highlight|
            Highlight.new(
              book_id: highlight['book_id'].to_s,
              color: highlight['color'],
              created_at: highlight['created_at'],
              end_location: highlight['end_location'],
              external_id: highlight['external_id'],
              highlight_id: highlight['id'].to_s,
              highlighted_at: highlight['highlighted_at'],
              is_discard: highlight['is_discard'],
              is_favorite: highlight['is_favorite'],
              location: highlight['location'],
              location_type: highlight['location_type'],
              note: highlight['note'],
              readwise_url: highlight['readwise_url'],
              tags: highlight['tags'].map do |tag|
                Tag.new(
                  tag_id: tag['id'].to_s,
                  name: tag['name']
                )
              end,
              text: highlight['text'],
              updated_at: highlight['updated_at'],
              url: highlight['url'],
            )
          end
        )
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
        tags: res['tags'].map do |tag|
          Tag.new(
            tag_id: tag['id'].to_s,
            name: tag['name']
          )
        end,
        text: res['text'],
        updated_at: res['updated_at'],
        url: res['url'],
      )
    end

    def get_readwise_request(url)
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Token #{@token}"
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      
      raise Error, 'Export request failed' unless res.is_a?(Net::HTTPSuccess)
  
      JSON.parse(res.body)
    end
  end
end
