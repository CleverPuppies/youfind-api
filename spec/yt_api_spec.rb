# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

require_relative '../lib/youtube_api'

VIDEO_ID = '8bZh5LMaSmE'
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
YT_API_KEY = CONFIG['API_KEY']
CORRECT = YAML.safe_load(File.read('spec/fixtures/yt_results.yml'))

describe 'Tests Youtube API library' do
  describe 'Video information' do
    it 'HAPPY: should provide correct video info' do
      video = YouFind::YoutubeAPI.new(YT_API_KEY)
                                 .video(VIDEO_ID)
      _(video.title).must_equal CORRECT['title']
      _(video.url).must_equal CORRECT['url']
      _(video.id).must_equal CORRECT['id']
      _(video.duration).must_equal CORRECT['duration']
      # _(video.views).must_equal CORRECT['views'] DON'T CHECK NUMBER OF VIEWS BECAUSE IT IS CONSTANTLY INCREASING
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        YouFind::YoutubeAPI.new('BAD_TOKEN').video('cleverpuppies')
      end).must_raise YouFind::YoutubeAPI::Errors::Forbidden
    end
  end

  describe 'Captions' do
    before do
      @video = YouFind::YoutubeAPI.new(YT_API_KEY).video(VIDEO_ID)
    end

    it 'HAPPY: should be able to retrieve captions' do
      _(@video.captions).wont_be_nil
    end
    
    it 'HAPPY: should have start, duration, text' do
      first_caption = @video.captions.first
      _(first_caption['start']).must_equal CORRECT['captions'][0]['start']
      _(first_caption['dur']).must_equal CORRECT['captions'][0]['dur']
      _(first_caption['text']).must_equal CORRECT['captions'][0]['text']
    end
  end
end