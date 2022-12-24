# frozen_string_literal: true

require 'http'

module YouFind
  # Library for Youtube Web API
  module Youtube
    # Library for Youtube web API
    class CommentsAPI
      def initialize(api_key)
        @yt_key = api_key
      end

      def video_comments(video_id)
        Request.new(@yt_key).comments(video_id)
      end

      # Sends out HTTP request to Youtube
      class Request
        COMMENTS_PATH = 'https://www.googleapis.com/youtube/v3/commentThreads'
        REPLIES_PATH = 'https://www.googleapis.com/youtube/v3/comments'

        def initialize(api_key)
          @yt_key = api_key
        end

        def comments(video_id)
          comments = []
          nextPageToken = ''
          params = {
            :key => @yt_key,
            :videoId => video_id,
            :textFormat => 'plainText',
            :part => 'snippet',
            :maxResults => 100
          }
          
          loop do
            params[:pageToken] = nextPageToken
            
            comments.append(retrieve(COMMENTS_PATH, params))
            response = JSON.parse(comments.last)

            response['items'].each do |comment|
              if comment['snippet']['totalReplyCount'] > 0
                comments.concat(comment_replies(comment['id']))
                break
              end
            end

            nextPageToken = response['nextPageToken']
            break if nextPageToken.nil?
          end
          comments
        end

        def comment_replies(comment_id)
          replies = []
          nextPageToken = ''
          params = {
            :key => @yt_key,
            :parentId => comment_id,
            :textFormat => 'plainText',
            :part => 'snippet',
            :maxResults => 100
          }

          loop do
            params[:pageToken] = nextPageToken
            
            replies.append(retrieve(REPLIES_PATH, params))

            nextPageToken = JSON.parse(replies.last)['nextPageToken']
            break if nextPageToken.nil?
          end

          replies
        end

        def retrieve(url, params)
          http_response = HTTP.get(url, params: params)
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
          !HTTP_ERROR.keys.include?(code)
        end

        def raise_error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
