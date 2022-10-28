require 'roda'
require 'slim'

module YouFind
    class App < Roda
        plugin:render, engine: 'slim', views: 'app/views'
        plugin:assets, css: 'style.css', path: 'app/views/assets'
        plugin :common_logger, $stderr
        plugin:halt
        
        route do |routing|
            routing.assets # load custom CSS
            puts routing.assets
            
            # GET /
            routing.root do
                view 'home'
            end
            
            routing.on 'video' do
                routing.is do
                    # POST /video/
                    routing.post do
                        yt_video_url = routing.params['yt_video_url']
                        puts "->"
                        puts yt_video_url
                        routing.halt 400 unless (yt_video_url.include? 'youtube.com') &&
                                                (yt_video_url.include? 'v=') &&
                                                (yt_video_url.split('v=').count == 2) &&
                                                (yt_video_url.split('v=')[1].length == 11)
                        video_id = yt_video_url.split('v=')[1]
                        routing.redirect "video/#{video_id}"
                    end
                end
                
                routing.on String do |video_id|
                    # GET /video/id/captions
                    routing.get do
                        video_data= YoutubeAPI::VideoMapper
                            .new(YT_TOKEN)
                            .find(video_id)

                        view 'video', locals: { data: video_data}
                    end
                end
            end
        end
    end
end