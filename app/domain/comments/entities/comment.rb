# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module YouFind
  module Entity
    # Domain entity for videos
    class Comment < Dry::Struct
      include Dry.Types

      attribute :id,            Integer.optional
      attribute :yt_comment_id, Strict::String
      attribute :text,          Strict::String

      def to_attr_hash
        to_hash.except(:id, :captions)
      end
    end
  end
end
