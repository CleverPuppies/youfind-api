# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'AddVideo Service Integration Test' do
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

    it 'HAPPY: should be able to find and save remote video to database' do
      video = YouFind::RapidAPI::VideoMapper
              .new(RAPIDAPI_API_KEY)
              .find(VIDEO_ID)

      video_saved = YouFind::Service::AddVideo.new.call(video_id: VIDEO_ID)

      _(video_saved.success?).must_equal true

      rebuilt = video_saved.value!.message

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
  end
end
