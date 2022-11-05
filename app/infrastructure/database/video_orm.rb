require 'sequel'

module YouFind
    module Database
        # Object Relational Mapper for Video Entities
        class VideoOrm < Sequel::Model(:videos)
            one_to_many :captions,
                    class: :'YouFind::Database::CaptionOrm',
                    key: :video_id

            plugin :timestamps, update_on_create: true

            def self.find_or_create(video_info)
                first(origin_id: video_info[:origin_id]) || create(video_info)
            end
        end
    end
end