# frozen_string_literal: true

require 'roda'
require 'slim'

module YouFind
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      routing.assets # load custom CSS

      # GET /
      routing.root do
        view 'home'
      end

      routing.on 'video' do
        routing.is do
          # POST /video/
          routing.post do
            yt_video_url = routing.params['yt_video_url']
            routing.halt 400 unless Inputs::VideoUrlMapper.new(yt_video_url).valid?
            video_id = yt_video_url.split('v=')[1]
            routing.redirect "video/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /video/id/
          routing.get do
            video_data = Repository::Videos.find_origin_id(video_id)
            if video_data.nil?
              video_data = Youtube::VideoMapper.new(ENV.fetch('RAPID_API_TOKEN', nil)).find(video_id)
              Repository::Videos.create(video_data)
            end
            view 'video', locals: { data: video_data, text: routing.params['text'] }
          end
        end
      end
    end
  end
end
