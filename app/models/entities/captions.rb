# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for team members
    class Captions < Dry::Struct
      include Dry.Types

      attribute :transcript,  Strict::Array.of(Strict::Hash.schema(
        start:  Strict::String,
        dur:    Strict::String,
        text:   Strict::String
      ).with_key_transform(&:to_sym))
    end
  end
end