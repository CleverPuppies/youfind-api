# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for video captions
    class VideoUrl < Dry::Struct
      include Dry.Types

      attribute :url,        Strict::String

      def valid?
        (@url.include? 'youtube.com') &&
        (@url.include? 'v=') &&
        (@url.split('v=')[1].length == 11)
      end
    end
  end
end
