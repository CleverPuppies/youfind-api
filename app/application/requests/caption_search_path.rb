# frozen_string_literal: true

module YouFind
  module Request
    # Application value for the path of caption search
    class CaptionSearchPath
      def initialize(video_id, params)
        @video_id = video_id
        @text = params['text']
      end

      attr_reader :video_id, :text
    end
  end
end
