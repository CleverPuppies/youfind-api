# frozen_string_literal: true

require_relative 'progress_publisher'

module CollectComment
  # Reports job progress to client
  class JobReporter
    attr_accessor :video_id

    def initialize(request_json, config)
      puts request_json
      collect_request = YouFind::Representer::CollectRequest
                        .new(OpenStruct.new)
                        .from_json(request_json)

      @video_id = collect_request.video_id
      @publisher = ProgressPublisher.new(config, collect_request.id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
