# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load(File.read('config/secrets.yml'))

def yt_api_path(path = '')
  "https://ytube-videos.p.rapidapi.com/#{path}"
end

def get_yt_url(config, url, video_id)
  HTTP.headers('X-RapidAPI-Key' => config['API_KEY'],
               'X-RapidAPI-Host' => 'ytube-videos.p.rapidapi.com').get(url, params: { id: video_id })
end

yt_response = {}
yt_results = {}

# Get info for Sandi Metz video
video_url = yt_api_path('info')
yt_response[video_url] = get_yt_url(config, video_url, '8bZh5LMaSmE')
video = yt_response[video_url].parse[0]

yt_results['title'] = video['title']
yt_results['url'] = video['url']
yt_results['id'] = video['id']['videoId']
yt_results['duration'] = video['duration_raw']
yt_results['views'] = video['views']

# List captions for Sandi Metz video https://www.youtube.com/watch?v=8bZh5LMaSmE
caption_url = yt_api_path('captions')

yt_response[caption_url] = get_yt_url(config, caption_url, '8bZh5LMaSmE')

captions = yt_response[caption_url].parse

yt_results['captions'] = captions

captions.count
# 956 caption items

File.write('spec/fixtures/yt_results.yml', yt_results.to_yaml)
