# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load(File.read('config/secrets.yml'))

def yt_api_path(path = '')
  "https://ytube-videos.p.rapidapi.com/#{path}"
end

def call_yt_url(config, url, video_id)
  HTTP.headers('X-RapidAPI-Key' => config['API_KEY'],
               'X-RapidAPI-Host' => 'ytube-videos.p.rapidapi.com').get(url, params: { id: video_id })
end

yt_response = {}
yt_results = {}

# List captions for Sandi Metz video https://www.youtube.com/watch?v=8bZh5LMaSmE
caption_url = yt_api_path('captions')

yt_response[caption_url] = call_yt_url(config, caption_url, '8bZh5LMaSmE')

captions = yt_response[caption_url].parse

yt_results['captions'] = captions

captions.count
# 956 caption items

File.write('spec/fixtures/yt_response.yml', yt_response.to_yaml)
File.write('spec/fixtures/yt_results.yml', yt_results.to_yaml)
