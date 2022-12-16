# frozen_string_literal: true

module YouFind
  # module for helper functions used in the routing
  module RouteHelpers
    def check_service_response(response, routing)
      puts response.failure?
      return unless response.failure?

      failed = Representer::HttpResponse.new(response.failure)
      routing.halt failed.http_status_code, failed.to_json
    end
  end
end
