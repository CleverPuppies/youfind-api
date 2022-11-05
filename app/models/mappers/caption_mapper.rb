# frozen_string_literal: false

module YouFind
  # Provides access to contributor data
  module Youtube
    # Data Mapper: Github contributor -> Member entity
    class CaptionMapper
      def initialize(yt_token, gateway_class = Youtube::API)
        @token = yt_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def load_captions(video_id)
        @gateway.video_captions(video_id).map do |caption|
          CaptionMapper.build_entity(caption)
        end
      end

      def self.build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          YouFind::Entity::Caption.new(
            id: nil,
            start: start,
            duration: duration,
            text: text
          )
        end

        private

        def start
          @data['start']
        end

        def duration
          @data['dur']
        end

        def text
          @data['text']
        end
      end
    end
  end
end
