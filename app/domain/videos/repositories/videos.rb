# frozen_string_literal: true

module YouFind
  module Repository
    # Repository for Video Entities
    class Videos
      def self.find_captions(entity, text)
        # SELECT * FROM captions WHERE id = origin_id AND text LIKE "%#{text}%"
        video_record = Database::VideoOrm.first(origin_id: entity.origin_id)
        
        searching_words = YouFind::Inputs::WordsInputMapper.new(ENV.fetch('RAPID_API_TOKEN', nil))
                                                           .find_associations(text)

        Captions.rebuild_many Database::CaptionOrm
          .where(video_id: video_record.id)
          .where(Sequel.like(:text, "%#{text}%"))
          .all
      end

      def self.find(entity)
        # SELECT * FROM videos WHERE origin_id = entity.origin_id
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        # SELECT * FROM videos WHERE id = id
        rebuild_entity Database::VideoOrm.first(id: id)
      end

      def self.find_origin_id(origin_id)
        # SELECT * FROM videos WHERE origin_id = origin_id
        rebuild_entity Database::VideoOrm.first(origin_id: origin_id)
      end

      def self.create(entity)
        raise 'Video already exists' if find(entity)

        db_video = PersistVideo.new(entity).call
        rebuild_entity(db_video)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Video.new(
          db_record.to_hash.merge(
            captions: Captions.rebuild_many(db_record.captions)
          )
        )
      end

      def self.db_find_or_create(entity)
        Database::VideoOrm.find_or_create(entity.to_attr_hash)
      end

      # Helper class to persist object and its members to database
      class PersistVideo
        def initialize(entity)
          @entity = entity
        end

        def create_video
          Database::VideoOrm.create(@entity.to_attr_hash)
        end

        def call
          create_video.tap do |db_video|
            @entity.captions.each do |caption|
              db_video.add_caption(Captions.create(caption))
            end
          end
        end
      end
    end
  end
end
