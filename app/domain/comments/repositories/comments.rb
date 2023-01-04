# frozen_string_literal: true

module YouFind
  module Repository
    # Repository for Video Entities
    class Comments
      def self.find(entity)
        # SELECT * FROM videos WHERE origin_id = entity.origin_id
        rebuild_entity Database::CommentOrm.first(yt_comment_id: entity.yt_comment_id)
      end

      def self.find_id(id)
        # SELECT * FROM comments WHERE id = id
        rebuild_entity Database::CommentOrm.first(id: id)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Comment.new(
          id: db_record.id,
          yt_comment_id: db_record.yt_comment_id,
          text: db_record.text
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_comment|
          Comments.rebuild_entity(db_comment)
        end
      end

      def self.create(video, entity)
        return if find(entity)

        db_comment = PersistComment.new(video, entity).call
        rebuild_entity(db_comment)
      end

      def self.find_comments(video_pk)
        # SELECT * FROM comments WHERE video_id = video_id
        Comments.rebuild_many Database::CommentOrm
          .where(video_id: video_pk)
          .all
      end

      # Helper class to persist object and its members to database
      class PersistComment
        def initialize(video, entity)
          @video = video
          @entity = entity
        end

        def create_comment
          Database::CommentOrm.create(@entity.to_attr_hash)
        end

        def call
          create_comment.tap do |db_comment|
            # TODO: Map video entity to ORM
            Repository::For.klass(Entity::Video).add_comment(@video, db_comment)
          end
        end
      end
    end
  end
end
