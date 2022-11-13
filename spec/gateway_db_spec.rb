# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests for Youtube API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store video' do
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
      _(rebuilt.embedded_url).must_equal(video.embedded_url)
      _(rebuilt.time).must_equal(video.time)
      _(rebuilt.views).must_equal(video.views)

      _(rebuilt.captions[10].start).must_equal(video.captions[10].start)
      _(rebuilt.captions[10].duration).must_equal(video.captions[10].duration)
      _(rebuilt.captions[10].text).must_equal(video.captions[10].text)
    end

    it 'HAPPY: should be able to do caption search' do
      video = YouFind::Youtube::VideoMapper
              .new(YT_API_KEY)
              .find(VIDEO_ID)

      YouFind::Repository::For.entity(video).create(video)

      _(YouFind::Repository::For.entity(video).find_caption(video, 'Google')[0].text)
        .must_equal "And so, it is so famous\nthat you can just Google it,"
    end
  end
end
