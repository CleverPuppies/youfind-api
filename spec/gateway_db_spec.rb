# frozen_string_literal: false

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Youtube Videos API from RapidAPI and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store project' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save video from Youtube to database' do
      video = YouFind::Youtube::VideoMapper
                .new(YT_API_KEY)
                .find(VIDEO_ID)

      rebuilt = YouFind::Repository::For.entity(video).create(video)

      _(rebuilt.origin_id).must_equal(video.origin_id)
      _(rebuilt.title).must_equal(video.title)
      _(rebuilt.url).must_equal(video.url)
      _(rebuilt.time).must_equal(video.time)

      video.captions.each do |caption|
        found = rebuilt.captions.find do |potential|
          potential.text == caption.text
        end

        _(found.start).must_equal caption.start
        _(found.duration).must_equal caption.duration
      end
    end
  end
end