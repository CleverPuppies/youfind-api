# frozen_string_literal: false


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
        begin
          data = JSON.parse @gateway.words_associations(input).body
          build_entity(data).word_collection
        rescue
          [input]
        end
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
            input: input,
            associations: associations
          )
        end

        private

        def input
          @data['response'].keys
        end

        def associations
          @data['associations_array']
        end
      end
    end
  end
end
