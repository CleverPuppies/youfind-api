# frozen_string_literal: false

module YouFind
    # Provides access to contributor data
    module YoutubeAPI
      # Data Mapper: Github contributor -> Member entity
      class CaptionsMapper
        def initialize(yt_token, gateway_class = YoutubeAPI::API)
          @token = yt_token
          @gateway_class = gateway_class
          @gateway = @gateway_class.new(@token)
        end
  
        def load_captions(video_id)
          data = @gateway.video_captions(video_id)
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
            YouFind::Entity::Captions.new(
              transcript:
            )
          end
  
          private
  
          def transcript
            @data
          end
        end
      end
    end
  end