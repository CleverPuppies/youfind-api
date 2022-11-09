# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for word input to search inside captions
    class FilterInput < Dry::Struct
      include Dry.Types

      attribute :input,        Strict::String
      attribute :associations, Strict::Array.of(String)

      def to_attr_hash
        to_hash.except(:input)
      end
    end
  end
end
