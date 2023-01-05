# frozen_string_literal: false

require_relative 'caption_mapper'

module YouFind
  # Provides access to contributor data
  module RapidAPI
    # Data Mapper: Github contributor -> Member entity
    class VideoMapper
      def initialize(yt_token, gateway_class = RapidAPI::VideoAPI)
        @token = yt_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(video_id)
        data = @gateway.video_data(video_id)
        data['embedded_url'] = "https://www.youtube.com/embed/#{video_id}"
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class)
          @data = data
          @caption_mapper = CaptionMapper.new(token, gateway_class)
        end

        def build_entity
          YouFind::Entity::Video.new(
            id: nil,
            origin_id: video_id,
            title: title,
            url: url,
            embedded_url: embedded_url,
            time: time,
            views: views,
            captions: captions
          )
        end

        private

        def video_id
          @data['id']['videoId']
        end

        def title
          @data['title']
        end

        def url
          @data['url']
        end

        def embedded_url
          @data['embedded_url']
        end

        def time
          @data['duration_raw']
        end

        def views
          @data['views']
        end

        def captions
          @caption_mapper.load_captions(video_id)
        end
      end
    end
  end
end
