# frozen_string_literal: true

require 'http'

module YouFind
  # Library for Youtube Web API
  module Youtube
    # Library for Youtube web API
    class API
      def initialize(api_key)
        @yt_key = api_key
      end

      def video_data(video_id)
        Request.new(@yt_key).video(video_id).parse[0]
      end

      def video_captions(video_id)
        Request.new(@yt_key).captions(video_id).parse
      end

      # Sends out HTTP request to Youtube
      class Request
        VIDEOS_PATH = 'https://ytube-videos.p.rapidapi.com/info'
        CAPTIONS_PATH = 'https://ytube-videos.p.rapidapi.com/captions'

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
          http_response = HTTP.headers(
            'X-RapidAPI-Key' => @yt_key,
            'X-RapidAPI-Host' => 'ytube-videos.p.rapidapi.com'
          ).get(url, params: params)
          puts http_response
          Response.new(http_response).tap do |response|
            raise(response.raise_error) unless response.successful?
          end
        end
      end

      # Decorates HTTP responses from Youtube with success/error
      class Response < SimpleDelegator
        # Returned when caption is requested for video that doesn't exist
        BadRequest = Class.new(StandardError)
        # Returned when API key is not registered
        Forbidden = Class.new(StandardError)

        HTTP_ERROR = {
          400 => BadRequest,
          403 => Forbidden
        }.freeze

        def successful?
          !HTTP_ERROR.keys.include?(code) && body.to_s != '[]'
        end

        def raise_error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
