# frozen_string_literal: false

module YouFind
    # Provides access to contributor data
    module Youtube
      # Data Mapper: Github contributor -> Member entity
      class CommentMapper
        def initialize(yt_token, gateway_class = Youtube::CommentsAPI)
          @token = yt_token
          @gateway_class = gateway_class
          @gateway = @gateway_class.new(@token)
        end
  
        def load_comments(video_id)
          @gateway.video_comments(video_id).map do |comments|
            comments_data = JSON.parse(comments)['items']
            comments_data.map do |comment|
              if comment.dig('snippet', 'topLevelComment')
                entity_data = comment['snippet']['topLevelComment']['snippet']
              else
                entity_data = comment['snippet']
              end
              entity_data['yt_comment_id'] = comment['id']
              CommentMapper.build_entity(entity_data)
            end
          end.flatten
        end
  
        def self.build_entity(data)
          DataMapper.new(data).build_entity
        end
  
        # Extracts entity specific elements from data structure
        class DataMapper
          def initialize(data)
            @data = data
          end
  
          def build_entity
            YouFind::Entity::Comment.new(
              id: nil,
              yt_comment_id: yt_comment_id,
              text: text
            )
          end
  
          private

          def yt_comment_id
            @data['yt_comment_id']
          end
  
          def text
            @data['textOriginal']
          end
        end
      end
    end
  end
  