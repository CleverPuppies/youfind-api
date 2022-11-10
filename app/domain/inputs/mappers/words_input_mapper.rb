# frozen_string_literal: false

require_relative 'caption_mapper'

module YouFind
  # Provides access to the input YouTube video url
  module Inputs
    # Data Mapper: Github contributor -> Member entity
    class WordsInputMapper
      def initialize(api_token, gateway_class = WordsAssociation::API)
        @token = api_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find_associations(input)
        data = @gateway.words_associations(input)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          YouFind::Entity::WordsInput.new(
            input: @data['response'].keys,
            associations: @data['associations_array']
          )
        end

        private

        def url
          @data
        end
      end
    end
  end
end
