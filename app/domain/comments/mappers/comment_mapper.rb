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
        response = @gateway.video_comments(video_id)
        
        response.map do |comments|
          comments_data = JSON.parse(comments)['items']
          puts "[BEFORE] #{comments_data.length} - #{comments_data.class}"
          comments_data = comments_cleaner(comments_data)
          puts "[AFTER] #{comments_data.length} - #{comments_data.class}"

          comments_data.map do |comment|
            entity_data = if comment.dig('snippet', 'topLevelComment', 'snippet')
                            comment['snippet']['topLevelComment']['snippet']
                          else
                            comment['snippet']
                          end
            entity_data['yt_comment_id'] = comment['id']
            CommentMapper.build_entity(entity_data)
          end
        end.flatten
      end

      def comments_cleaner(comments) #make it a ! function
        comments.map do |comment|
          time_tag_regex = /[0-9]+:[0-9]+(?::[0-9]+|)/
          text = comment['snippet']['textOriginal']
          if comment.dig('snippet', 'topLevelComment', 'snippet')
            text = comment['snippet']['topLevelComment']['snippet']['textOriginal']
          end
            if time_tag_regex.match?(text)
            comment
          else
            nil
          end
        end.compact
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
