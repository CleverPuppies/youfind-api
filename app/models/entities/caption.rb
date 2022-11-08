# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for video captions
    class Caption < Dry::Struct
      include Dry.Types

      attribute :id,        Integer.optional
      attribute :start,     Coercible::Float
      attribute :duration,  Coercible::Float
      attribute :text,      Strict::String

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
