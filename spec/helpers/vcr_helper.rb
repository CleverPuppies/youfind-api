# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'youtube_api'

  def self.setup_vcr
    VCR.configure do |vcr_config|
      vcr_config.cassette_library_dir = CASSETTES_FOLDER
      vcr_config.hook_into :webmock
      vcr_config.ignore_localhost = true # for acceptance tests
      vcr_config.ignore_hosts 'sqs.us-east-1.amazonaws.com'
      vcr_config.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  def self.configure_vcr_for_youtube(recording: :new_episodes)
    VCR.configure do |config|
      config.filter_sensitive_data('<RAPIDAPI_KEY>') { RAPIDAPI_API_KEY }
      config.filter_sensitive_data('<RAPIDAPI_KEY_ESC>') { CGI.escape(RAPIDAPI_API_KEY) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: recording,
      match_requests_on: %i[method uri headers],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
