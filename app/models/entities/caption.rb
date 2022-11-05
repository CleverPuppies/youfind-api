# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for video captions
    class Caption < Dry::Struct
      include Dry.Types

      attribute :start,     Strict::String
      attribute :duration,  Strict::String
      attribute :text,      Strict::String
    end
  end
end
