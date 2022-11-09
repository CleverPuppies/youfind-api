# frozen_string_literal: true

module YouFind
  module Repository
    # Repository for Caption
    class Captions
      def self.find_id(id)
        # SELECT * FROM captions WHERE id = id
        rebuild_entity Database::CaptionOrm.first(id: id)
      end

      # def self.string_match_captions(video_id, text)
      #   # SELECT * FROM captions WHERE id = video_id AND text LIKE "%#{text}%"
      #   rebuild_many Database::CaptionOrm.all(id: video_id, Sequel.like(:text, "%#{text}%"))
      # end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Caption.new(
          id: db_record.id,
          start: db_record.start,
          duration: db_record.duration,
          text: db_record.text
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_caption|
          Captions.rebuild_entity(db_caption)
        end
      end

      def self.create(entity)
        Database::CaptionOrm.create(entity.to_attr_hash)
      end
    end
  end
end
