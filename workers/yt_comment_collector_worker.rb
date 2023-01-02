# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to collect comments in parallel
class YtCommentCollectorWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config() = Figaro.env

  YT_NOT_FOUND_ERR = 'No comments found on YouTube'

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.COMMENT_COLLECTOR_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    video_representer = YouFind::Representer::Video
      .new(OpenStruct.new).from_json(request)
    
    video = YouFind::Repository::For.klass(YouFind::Entity::Video)
      .find_origin_id(video_representer.origin_id)

    # puts YouFind::Database::VideoOrm.all
    comments = YouFind::Youtube::CommentMapper
      .new(YtCommentCollectorWorker.config.YOUTUBE_API_KEY)
      .load_comments(video)

    # TODO: Create a method in Repository::Comment to store comments and reference to video
    comments.each do |comment|
      YouFind::Repository::Comments.create(video, comment)
    end
  # rescue StandardError
  #   raise 'YT_NOT_FOUND_ERR'
  end
end
