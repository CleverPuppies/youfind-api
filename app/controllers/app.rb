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

    route do |routing|
      routing.assets # load custom CSS
      # puts routing.assets

      # GET /
      routing.root do
        view 'home'
      end

      routing.on 'video' do
        routing.is do
          # POST /video/
          routing.post do
            yt_video_url = routing.params['yt_video_url']
            routing.halt 400 unless Inputs::VideoUrl(yt_video_url).valid?
            video_id = yt_video_url.split('v=')[1]
            routing.redirect "video/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /video/id/captions
          routing.get do
            video_data = Repository::Videos.find_origin_id(video_id)
            if video_data.nil?
              video_data = Youtube::VideoMapper.new(ENV.fetch('YT_TOKEN', nil)).find(video_id)
              Repository::Videos.create(video_data)
            end
            view 'video', locals: { data: video_data }
          end
        end
      end
    end
  end
end
