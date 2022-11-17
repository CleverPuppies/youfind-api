# frozen_string_literal: false

require_relative 'caption_mapper'

module YouFind
  # Provides access to the input YouTube video url
  module Inputs
    # Data Mapper: Github contributor -> Member entity
    class VideoUrlMapper
      def initialize(url)
        @url = url
      end

      def valid?
        (@url.include? 'youtube.com') &&
        (@url.include? 'v=') &&
        (@url.split('v=')[1].length == 11)
      end
    end
  end
end
