# frozen_string_literal: true

require 'http'

module YouFind
  # Library for Words Association Web API
  module WordsAssociation
    # Library for Words Association web API
    class API
      def initialize(api_key)
        @words_assos_key = api_key
      end

      def words_associations(text)
        Request.new(@words_assos_key).video(video_id).parse[0]
      end

      # Sends out HTTP request to Youtube
      class Request
        ASSOCIATIONS_PATH = 'https://twinword-word-associations-v1.p.rapidapi.com/associations/'

        def initialize(api_key)
          @words_assos_key = api_key
        end

        def associations(words)
          retrieve(ASSOCIATIONS_PATH, { entry: words })
        end

        def retrieve(url, params)
          http_response = HTTP.headers(
            'X-RapidAPI-Key' => @words_assos_key,
            'X-RapidAPI-Host' => 'twinword-word-associations-v1.p.rapidapi.com'
          ).get(url, params: params)
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
          !HTTP_ERROR.keys.include?(code) && body['result_msg'] == 'Success'
        end

        def raise_error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
