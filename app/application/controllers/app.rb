# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module YouFind
  # Web App
  class App < Roda
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      routing.assets # load CSS

      # GET /
      routing.root do
        view 'home'
      end

      routing.on 'video' do # rubocop:disable Metrics/BlockLength
        routing.is do
          # POST /video/
          routing.post do
            # url_request = Forms::NewVideo.new.call(routing.params)

            yt_video_url = routing.params['yt_video_url']
            unless (yt_video_url.include? 'youtube.com') &&
                   (yt_video_url.include? 'v=') &&
                   (yt_video_url.split('v=')[1].length == 11)
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
            begin
              if video_data.nil?
                video_data = Youtube::VideoMapper.new(App.config.RAPID_API_TOKEN)
                                                 .find(video_id)
              end
            rescue StandardError => e # TODO: Specifically catch BadRequestError
              App.logger.error e
              flash[:error] = 'Could not find the video'
              routing.redirect '/'
            end

            # Add video to database
            begin
              Repository::For.klass(video_data).create(video_data)
            rescue StandardError => e
              App.logger.error e.backtrace.join("\n")
              flash[:error] = 'Having trouble accessing the database'
            end

            video = Views::Video.new(
              video_data,
              routing.params['text'] || ''
            )
            view 'video', locals: { video: video }
          end
        end
      end
    end
  end
end
