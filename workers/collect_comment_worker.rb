# frozen_string_literal: true

require_relative '../require_app'
require_relative 'collect_monitor'
require_relative 'job_reporter'
require_app

require 'figaro'
require 'shoryuken'

module CollectComment
  # Shoryuken worker class to collect comments in parallel
  class Worker
    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: ENV['RACK_ENV'] || 'development',
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    YT_NOT_FOUND_ERR = 'No comments found on YouTube'

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    shoryuken_options queue: config.COMMENT_COLLECTOR_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config)

      job.report(CollectMonitor.starting_percent)

      video = YouFind::Repository::For.klass(YouFind::Entity::Video).find_origin_id(job.video_id)

      comments = YouFind::Youtube::CommentMapper
                 .new(Worker.config.YOUTUBE_API_KEY)
                 .load_comments(job.video_id)

      job.report(CollectMonitor.storing_percent)

      comments.each do |comment|
        YouFind::Repository::Comments.create(video, comment)
      end

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(5) { CollectMonitor.finished_percent }
    end
  end
end
