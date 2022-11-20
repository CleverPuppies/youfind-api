# frozen_string_literal: true

require 'roda'
require 'slim'

module YouFind
  # Web App
  class App < Roda
    plugin :flash
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
            unless Inputs::VideoUrlMapper.new(yt_video_url).valid?
              flash[:error] = 'Invalid URL for a Youtube video'
              response.status = 400
              routing.redirect '/'
            end
            video_id = yt_video_url.split('v=')[1]
            routing.redirect "video/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /video/id/
          routing.get do
            video_data = Repository::For.klass(Entity::Video)
              .find_origin_id(video_id)
            
            if video_data.nil?
              begin
                video_data = Youtube::VideoMapper.new(App.config.RAPID_API_TOKEN).find(video_id)
              rescue => err # TODO: Specifically catch BadRequestError
                logger.error err
                flash[:error] = 'Could not find the video'
                routing.redirect '/'
              end

              # Add video to database
              begin
                Repository::For.klass(video_data).create(video_data)
              rescue StandardError => err
                # summon logger
                logger.error err.backtrace.join("\n")
                flash[:error] = 'Having trouble accessing the database'
              end
            end
            view 'video', locals: { data: video_data, text: routing.params['text'] }
          end
        end
        
      end
    end
  end
end
