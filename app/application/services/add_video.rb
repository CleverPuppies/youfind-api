# frozen_string_literal: true

require 'dry/transaction'

module YouFind
  module Service
    # Transaction to store video from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :parse_url
      step :find_video
      step :store_video

      private

      def parse_url(input)
        if input.success?
          video_id = input[:yt_video_url].split('v=')[-1]
          Success(video_id: video_id)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def find_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_youtube(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(e.to_s)
      end

      def store_video(input)
        video =
          if (new_video = input[:remote_video])
            Repository::For.entity(new_video).create(new_video)
          else
            input[:local_video]
          end
        Success(video)
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def video_from_youtube(input)
        Youtube::VideoMapper
          .new(App.config.RAPID_API_TOKEN)
          .find(input[:video_id])
      rescue StandardError
        raise 'Could not find video on Youtube'
      end

      def video_in_database(input)
        Repository::For.klass(Entity::Video).find_origin_id(input[:video_id])
      end
    end
  end
end
