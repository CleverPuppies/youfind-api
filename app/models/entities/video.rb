# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

require_relative 'captions'

module YouFind
  module Entity
    # Domain entity for videos
    class Video < Dry::Struct
      include Dry.Types

      attribute :id,          Strict::String
      attribute :title,       Strict::String
      attribute :url,         Strict::String
      attribute :embedded_url, Strict::String
      attribute :duration,    Strict::String
      attribute :views,       Strict::String
      attribute :captions,    Captions
    end
  end
end
