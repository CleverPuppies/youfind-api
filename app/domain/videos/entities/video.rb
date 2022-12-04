# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

require_relative 'caption'

module YouFind
  module Entity
    # Domain entity for videos
    class Video < Dry::Struct
      include Dry.Types

      attribute :id,            Integer.optional
      attribute :origin_id,     Strict::String
      attribute :title,         Strict::String
      attribute :url,           Strict::String
      attribute :embedded_url,  Strict::String
      attribute :time,          Strict::String
      attribute :views,         Strict::String
      attribute :captions,      Strict::Array.of(Caption)

      def video_id
        origin_id
      end

      def to_attr_hash
        to_hash.except(:id, :captions)
      end

      def find_caption(text)
        self.captions = Repository::Videos.find_captions(self, text)
        self
      end

      private

      def captions=(new_captions)
        @attributes[:captions] = new_captions
      end
    end
  end
end
