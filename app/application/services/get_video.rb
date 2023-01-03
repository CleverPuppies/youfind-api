# frozen_string_literal: true

module YouFind
  module Service
    # Transaction to get video from db and filter its captions given a text param
    class GetVideo
      include Dry::Transaction

      step :retrieve_video

      private

      NOT_FOUND_ERR = 'Video not found'
      DB_ERR = 'Cannot access database'

      def retrieve_video(input)
        video = Repository::For.klass(Entity::Video).find_origin_id(
          input[:requested].video_id
        )

        raise NOT_FOUND_ERR if video.nil?

        Success(Response::ApiResult.new(status: :ok, message: video))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: NOT_FOUND_ERR))
      end
    end
  end
end
