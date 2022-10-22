require 'http'

require_relative 'video.rb'
require_relative 'captions.rb'

module YouFind
  class YoutubeAPI
    module Errors
      class BadRequest < StandardError; end
      class Forbidden < StandardError; end
    end

    HTTP_ERROR = {
      400 => Errors::BadRequest,
      403 => Errors::Forbidden
    }

    def initialize(api_key)
      @yt_key = api_key
    end

    def video(video_id)
      video_url = yt_api_path('info')
      video_data = call_yt_url(video_url, { id: video_id }).parse[0]
      Video.new(video_data, self)
    end

    def captions(video_id)
      caption_url = yt_api_path('captions')
      captions = call_yt_url(caption_url, {id: video_id}).parse
      Captions.new(captions)
    end

    private

    def yt_api_path(path)
      'https://ytube-videos.p.rapidapi.com/' + path
    end

    def call_yt_url(url, params={})
      result = HTTP.headers('X-RapidAPI-Key' => @yt_key,
                            'X-RapidAPI-Host' => 'ytube-videos.p.rapidapi.com').get(url, params: params)
      successful?(result) ? result : raise_error(result)
    end

    def successful?(result)
      HTTP_ERROR.keys.include?(result.code) ? false : true
    end

    def raise_error(result)
      raise(HTTP_ERROR[result.code])
    end
  end
end