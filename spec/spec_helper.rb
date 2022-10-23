# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'yaml'
require 'vcr'
require 'webmock'

Dir.chdir('../')
require_relative '../lib/youtube_api'

VIDEO_ID = '8bZh5LMaSmE'
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
YT_API_KEY = CONFIG['API_KEY']
CORRECT = YAML.safe_load(File.read('spec/fixtures/yt_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'youtube_api'
