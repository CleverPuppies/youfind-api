# frozen_string_literal: false

require_relative 'caption_mapper'

module YouFind
  # Provides access to the input YouTube video url
  module Inputs
    # Data Mapper: Github contributor -> Member entity
    class VideoUrlMapper
      def valid?(url)
        build_entity(url).valid?
      end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          YouFind::Entity::VideoUrl.new(
            url: @data
          )
        end

        private

        def url
          @data
        end
      end
    end
  end
end
