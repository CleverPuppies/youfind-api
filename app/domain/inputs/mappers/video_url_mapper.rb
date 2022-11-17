# frozen_string_literal: false

module YouFind
  # Provides access to the input YouTube video url
  module Inputs
    # Data Mapper: Github contributor -> Member entity
    class VideoUrlMapper
      def initialize(url)
        @url = url
      end

      def valid?
        YouFind::Entity::VideoUrl.new(url: @url).valid?
      end
    end
  end
end
