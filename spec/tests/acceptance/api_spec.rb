# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  YouFind::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Add video route' do
    it 'should be able to add a video' do
      post "api/v1/video/#{VIDEO_ID}"

      _(last_response.status).must_equal 201

      video = JSON.parse last_response.body
      _(video['origin_id']).must_equal VIDEO_ID

      video = YouFind::Representer::Video.new(
        YouFind::Representer::OpenStructWithLinks.new
      ).from_json last_response.body

      _(video.links['self'].href).must_include 'http'
    end

    it 'should report an error for invalid videos' do
      post 'api/v1/video/abcdefghijkl'

      _(last_response.status).must_equal 404

      response = JSON.parse last_response.body
      _(response['status']).must_equal 'not_found'
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get video route' do
    it 'should be able to get video' do
      # Add video
      YouFind::Service::AddVideo.new.call(video_id: VIDEO_ID)

      get "api/v1/video/#{VIDEO_ID}"
      _(last_response.status).must_equal 200

      response = JSON.parse last_response.body
      _(response['origin_id']).must_equal VIDEO_ID
      _(response['embedded_url']).must_include 'embed'
    end

    it 'should return subtitles that match the pattern' do
      # Add video
      YouFind::Service::AddVideo.new.call(video_id: VIDEO_ID)

      get "api/v1/video/#{VIDEO_ID}/captions", text: 'google'
      _(last_response.status).must_equal 200

      response = JSON.parse last_response.body
      _(JSON.parse(response[0])['text']).must_equal "and so, it is so famous\nthat you can just google it,"
    end
  end
end
