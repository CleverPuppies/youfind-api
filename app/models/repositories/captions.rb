module YouFind
  module Repository
    # Repository for Captions
    class Captions
      def self.find_id(id)
        rebuild_entity Database::CaptionOrm.first(id:)
      end
      
      def self.find_word(username)
        rebuild_entity Database::CaptionOrm.where("text like ?", "%#{username}%")
      end

      def self.create(entity)
        raise 'Caption already exists' if find(entity)
        
        db_caption = Database::CaptionOrm.create(@entity.to_attr_hash)
        rebuild_entity(db_caption)
      end

      def self.db_find_or_create(entity)
        Database::CaptionOrm.find_or_create(entity.to_attr_hash)
      end
        
      def self.rebuild_entity(db_record)
        return nil unless db_record
      
        Entity::Captions.new(
          id: db_record.id,
          start: db_record.start,
          duration: db_record.duration,
          text: db_record.text
        )
      end
        
      def self.rebuild_many(db_records)
        db_records.map do |db_member|
          Captions.rebuild_entity(db_member)
        end
      end
    end
  end
end