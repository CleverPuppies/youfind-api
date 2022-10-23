# frozen_string_literal: true

require_relative 'captions'

module YouFind
  # Model for Video
  class Video
    def initialize(video_data, data_source)
      @video = video_data
      @data_source = data_source
    end

    def title
      @video['title']
    end

    def url
      @video['url']
    end

    def id
      @video['id']['videoId']
    end

    def duration
      @video['duration_raw']
    end

    def views
      @video['views']
    end

    def captions
      @captions ||= @data_source.captions(id)
    end
  end
end
