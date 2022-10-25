# frozen_string_literal: false

require_relative 'captions_mapper'

module YouFind
    # Provides access to contributor data
    module YoutubeAPI
      # Data Mapper: Github contributor -> Member entity
      class VideoMapper
        def initialize(yt_token, gateway_class = YoutubeAPI::API)
          @token = yt_token
          @gateway_class = gateway_class
          @gateway = @gateway_class.new(@token)
        end

        def find(video_id)
            data = @gateway.video_data(video_id)
            build_entity(data)
        end
  
        def build_entity(data)
          DataMapper.new(data).build_entity
        end
  
        # Extracts entity specific elements from data structure
        class DataMapper
          def initialize(data)
            @data = data
            @captions_mapper = CaptionsMapper.new(
              token, gateway_class
            )
          end
  
          def build_entity
            YouFind::Entity::Video.new(
              video_id:,
              title:,
              url:,
              duration_raw:,
              views:,
              captions:
            )
          end
  
          private
          
          def video_id
            @video['id']['videoId']
          end

          def title
            @video['title']
          end
      
          def url
            @video['url']
          end
      
          def duration
            @video['duration_raw']
          end
      
          def views
            @video['views']
          end
      
          def captions
            @mcaptions_mapper.load_captions(@data['id']['video_id'])
          end
        end
      end
    end
  end