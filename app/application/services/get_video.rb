# frozen_string_literal: true

module YouFind
  module Service
    # Transaction to get video from db and filter its captions given a text param
    class GetVideo
      include Dry::Transaction

      step :retrieve_video
      step :filter_captions

      private

      NOT_FOUND_ERR = 'Video not found'
      DB_ERR = 'Cannot access database'

      def retrieve_video(input)
        video = Repository::For.klass(Entity::Video).find_origin_id(input[:video_id])
        raise NOT_FOUND_ERR if video.nil?

        input[:local_video] = video
        Success(input)
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end

      def filter_captions(input)
        video = input[:local_video]
        text = input[:text]
        video = text.nil? ? video : video.find_caption(text)
        Success(Response::ApiResult.new(status: :ok, message: video))
      end
    end
  end
end
