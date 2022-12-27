# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class YtCommentCollectorWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config() = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    video_id = JSON.parse(request)['video_id']
    comments = YouFind::Youtube::CommentMapper
      .new(config.YOUTUBE_API_KEY)
      .load_comments(video_id)
    comments.each do |comment|
      YouFind::Repository::Comments.create(comment)
  rescue StandardError
      raise YT_NOT_FOUND_ERR
  end
end