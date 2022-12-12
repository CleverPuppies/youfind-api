# frozen_string_literal: true

module YouFind
  module Service
    # Transaction to get captions filtered based on a given a http param
    class SearchCaption
      include Dry::Transaction

      step :retrieve_captions

      private

      NOT_FOUND_ERR = 'No subtitles found'
      DB_ERR = 'Cannot access database'

      def retrieve_captions(input)
        video = Repository::For.klass(Entity::Video).find_origin_id(input[:video_id])
        raise NOT_FOUND_ERR if video.nil?

        text = input[:text].nil? ? '' : input[:text]
        video = video.find_caption(text)
        Success(Response::ApiResult.new(status: :ok, message: video))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
