# frozen_string_literal: true

module YouFind
  module Request
    # Application value for the path of a requested video
    class VideoPath
      def initialize(video_id, request)
        @video_id = video_id
        @request = request
        @path = request.remaining_path
      end

      attr_reader :video_id
    end
  end
end
