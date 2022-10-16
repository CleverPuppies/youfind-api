# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load(File.read('config/secrets.yml'))

def yt_api_path(path = '')
  "https://youtube.googleapis.com/youtube/v3/captions/#{path}"
end

def call_yt_url(part, video_id, config)
  HTTP.get(yt_api_path, params: { part:, videoId: video_id, key: config['API_KEY'] })
end

yt_response = {}
yt_results = {}

# List captions for Sandi Metz video https://www.youtube.com/watch?v=8bZh5LMaSmE
list_caption_url = yt_api_path('')
yt_response[list_caption_url] = call_yt_url('snippet', '8bZh5LMaSmE', config)
captions = yt_response[list_caption_url].parse

yt_results['kind'] = captions['kind']
# What kind of response

yt_results['etag'] = captions['etag']
# etag of the video

yt_results['items'] = captions['items']

captions['items'].count
# 2 caption items

File.write('spec/fixtures/youtube_results', yt_results.to_yaml)
