# frozen_string_literal: true

require 'http'

module YouFind
  # Library for Youtube Web API
  module YoutubeAPI
    module Errors
      # Returned when caption is requested for video that doesn't exist
      class BadRequest < StandardError; end
      # Returned when API key is not registered
      class Forbidden < StandardError; end
    end

    class API
      def initialize(api_key)
        @yt_key = api_key
      end

      def video_data(video_id)
        Request.new(@yt_token).video(video_id).parse
      end

      def video_captions(video_id)
        Request.new(@yt_token).captions(video_id).parse
      end

      class Request
        VIDEOS_PATH = "https://ytube-videos.p.rapidapi.com/info"
        CAPTIONS_PATH = "https://ytube-videos.p.rapidapi.com/captions"

        def initialize(api_key)
          @yt_key = api_key
        end
        
        def video(video_id)
          retrieve(VIDEOS_PATH, { id: video_id })
        end

        def captions(video_id)
          retrieve(CAPTIONS_PATH, { id: video_id })
        end

        def retrieve(url, params)
          response = HTTP.headers(
            'X-RapidAPI-Key' => @yt_key,
            'X-RapidAPI-Host' => 'ytube-videos.p.rapidapi.com'
          ).get(url, params: params)
                       
          Response.new(response).tap do |response|
            raise(response.raise_error) unless response.successful?
          end
        end

      end

      class Response < SimpleDelegator
        BadRequest = Class.new(Errors::BadRequest)
        Forbidden = Class.new(Errors::Forbidden)

        HTTP_ERROR = {
          400 => Errors::BadRequest,
          403 => Errors::Forbidden
        }.freeze

        def successful?
          !HTTP_ERROR.keys.include?(code)
        end
    
        def raise_error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
