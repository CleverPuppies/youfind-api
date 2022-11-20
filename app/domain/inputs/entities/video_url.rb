# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for video captions
    class VideoUrl < Dry::Struct
      include Dry.Types

      attribute :url, Strict::String
    end
  end
end
