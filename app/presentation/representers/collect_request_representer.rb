# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'video_representer'

# Represents essential video information for API output
module YouFind
  module Representer
    # Representer object for comment collection status
    class CollectRequest < Roar::Decorator
      include Roar::JSON

      property :video, extend: Representer::Video, class: OpenStruct
      property :id
    end
  end
end
