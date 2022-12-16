# frozen_string_literal: true

require 'roda'

require_relative 'helpers'

module YouFind
  # Web App
  class App < Roda
    include RouteHelpers

    plugin :halt
    plugin :caching
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :common_logger, $stderr

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "YouFind API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'video' do
          routing.on String do |video_id|
            # POST /video/{video_id}
            routing.post do
              result = Service::AddVideo.new.call(video_id: video_id)
              check_service_response(result, routing)
              
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Video.new(result.value!.message).to_json
            end

            # GET /video/{video_id}/captions?text={captions_search_text}
            routing.on 'captions' do
              routing.get do
                result = Service::SearchCaptions.new.call(video_id: video_id, text: routing.params['text'])
                check_service_response(result, routing)

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code

                result.value!.message.map do |value|
                  Representer::Caption.new(value).to_json
                end.to_s
              end
            end

            # GET /video/{video_id}
            routing.get do
              response.cache_control public: true, max_age: 300

              path_request = Request::VideoPath.new(video_id, request)

              result = Service::GetVideo.new.call(requested: path_request)
              check_service_response(result, routing)

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Video.new(result.value!.message).to_json
            end
          end
        end
      end
    end
  end
end
