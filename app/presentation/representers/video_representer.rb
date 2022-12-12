# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'caption_representer'

module YouFind
  module Representer
    # Represent a Video entity as json
    class Video < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :title
      property :url
      property :embedded_url
      property :time
      property :views
      collection :captions, extend: Representer::Caption,
                            class: OpenStruct

      link :self do
        "#{App.config.API_HOST}/api/v1/video/#{origin_id}"
      end

      private

      def origin_id
        represented.origin_id
      end
    end
  end
end
