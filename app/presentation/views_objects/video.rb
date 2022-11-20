# frozen_string_literal: true

module Views
  # View for a single video entity
  class Video
    def initialize(video, text)
      @video = video
      @text = text
    end

    def origin_id
      @video.origin_id
    end

    def entity
      @video
    end

    def title
      @video.title
    end

    def views
      @video.views
    end

    def time
      @video.time
    end

    def url
      @video.url
    end

    def embedded_url
      @video.embedded_url
    end

    def captions
      return @video.captions if @text.nil? || @text.empty?

      @video.find_caption(@text)
    end
  end
end
