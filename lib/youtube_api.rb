# frozen_string_literal: true

require 'http'

require_relative 'video'
require_relative 'captions'

module YouFind
  # Library for Youtube Web API
  class YoutubeAPI
    module Errors
      # Returned when caption is requested for video that doesn't exist
      class BadRequest < StandardError; end
      # Returned when API key is not registered
      class Forbidden < StandardError; end
    end

    HTTP_ERROR = {
      400 => Errors::BadRequest,
      403 => Errors::Forbidden
    }.freeze

    def initialize(api_key)
      @yt_key = api_key
      @result = nil
    end

    def video(video_id)
      video_url = yt_api_path('info')
      video_data = get_yt_url(video_url, { id: video_id }).parse[0]
      Video.new(video_data, self)
    end

    def captions(video_id)
      caption_url = yt_api_path('captions')
      captions = get_yt_url(caption_url, { id: video_id }).parse
      Captions.new(captions)
    end

    private

    def yt_api_path(path)
      "https://ytube-videos.p.rapidapi.com/#{path}"
    end

    def get_yt_url(url, params = {})
      @result = HTTP.headers('X-RapidAPI-Key' => @yt_key,
                            'X-RapidAPI-Host' => 'ytube-videos.p.rapidapi.com').get(url, params: params)
      successful? ? @result : raise_error()
    end

    def successful?()
      !HTTP_ERROR.keys.include?(@result.code)
    end

    def raise_error()
      raise(HTTP_ERROR[@result.code])
    end
  end
end
