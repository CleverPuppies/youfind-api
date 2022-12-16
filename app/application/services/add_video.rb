# frozen_string_literal: true

require 'dry/transaction'

module YouFind
  module Service
    # Transaction to store video from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :find_video
      step :store_video

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      YT_NOT_FOUND_MSG = 'Could not find video on Youtube'

      # Expects input[:video_id]
      def find_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_youtube(input)
        end
        Success(input)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :not_found, message: YT_NOT_FOUND_MSG))
      end

      def store_video(input)
        video =
          if (new_video = input[:remote_video])
            Repository::For.entity(new_video).create(new_video)
          else
            input[:local_video]
          end
        Success(Response::ApiResult.new(status: :created, message: video))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # following are support methods that other services could use

      def video_from_youtube(input)
        Youtube::VideoMapper
          .new(App.config.RAPID_API_TOKEN)
          .find(input[:video_id])
      rescue StandardError
        raise YT_NOT_FOUND_MSG
      end

      def video_in_database(input)
        Repository::For.klass(Entity::Video).find_origin_id(input[:video_id])
      end
    end
  end
end
